from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from .schemas import ChatRequest, ChatResponse, Choice, ChoiceMsg
from .router_service import try_local, call_cloud
from .settings import settings
from .policy import cloud_allowed
from .cache import key_for_messages, cache_get, cache_set
from .db import Base, engine, SessionLocal
from .models import LogEntry
from .cost import estimate_cost
from .services.ocr import extract_text_from_image, extract_text_from_base64, format_ocr_text_for_prompt
import json
import uuid
import time
import base64

app = FastAPI(title="Local-first AI Router")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Create database tables
Base.metadata.create_all(bind=engine)


@app.post("/v1/chat/completions", response_model=ChatResponse)
def chat(req: ChatRequest):
    """OpenAI-compatible chat endpoint with local-first routing and OCR support."""
    messages = [m.dict() for m in req.messages]
    
    # Process OCR if image is provided
    if req.image:
        print("Processing image with OCR...")
        ocr_text, success = extract_text_from_base64(req.image)
        if success and ocr_text:
            print(f"OCR extracted {len(ocr_text)} characters from image")
            # Get the last user message
            if messages and messages[-1].get("role") == "user":
                original_content = messages[-1].get("content", "")
                # Prepend OCR text to the message
                ocr_formatted = format_ocr_text_for_prompt(ocr_text, original_content)
                messages[-1]["content"] = f"{ocr_formatted}\n\n{original_content}" if original_content else ocr_formatted
            else:
                # Create a new user message with OCR text
                messages.append({
                    "role": "user",
                    "content": format_ocr_text_for_prompt(ocr_text, "")
                })
        else:
            print("OCR extraction failed or returned no text")
    
    # Also check for images in message.image fields
    for msg in messages:
        if msg.get("image"):
            print("Processing image from message.image field...")
            ocr_text, success = extract_text_from_base64(msg["image"])
            if success and ocr_text:
                print(f"OCR extracted {len(ocr_text)} characters from message image")
                original_content = msg.get("content", "")
                ocr_formatted = format_ocr_text_for_prompt(ocr_text, original_content)
                msg["content"] = f"{ocr_formatted}\n\n{original_content}" if original_content else ocr_formatted

    requested_model = (req.model or "").strip()
    available_local_models = settings.LOCAL_MODELS or [settings.LOCAL_MODEL]
    local_model = settings.LOCAL_MODEL
    force_cloud = False

    if requested_model:
        req_lower = requested_model.lower()
        if requested_model in available_local_models:
            local_model = requested_model
        else:
            match = next((m for m in available_local_models if m.lower() == req_lower), None)
            if match:
                local_model = match
            else:
                starts_with_match = next((m for m in available_local_models if m.lower().startswith(req_lower)), None)
                if starts_with_match:
                    local_model = starts_with_match
                elif req_lower in {settings.CLOUD_MODEL.lower(), "cloud", "claude"}:
                    force_cloud = True
                elif req_lower.startswith("cloud"):
                    force_cloud = True

    cache_hint = requested_model or ("cloud" if force_cloud else local_model or "default")
    key = key_for_messages(messages, cache_hint)
    
    effective_temp = req.temperature if req.temperature is not None else settings.LOCAL_TEMPERATURE
    conversation_id = req.conversation_id or key
    
    # Check cache
    cached = cache_get(key, settings.CACHE_TTL_SECONDS)
    if cached:
        cached_response = dict(cached)
        cached_response["conversation_id"] = conversation_id
        return cached_response

    usage: dict = {}
    local_usage: dict = {}
    latency_ms = 0
    local_ms = 0
    confidence = 0.0
    answer = ""
    route = "local"

    if force_cloud:
        if not settings.ANTHROPIC_API_KEY:
            raise HTTPException(
                status_code=503,
                detail=(
                    "Cloud model requested but Anthropic API key is not configured. "
                    "Add your API key to the .env file: ANTHROPIC_API_KEY=sk-ant-... "
                    "Get your key from: https://console.anthropic.com/"
                )
            )
        try:
            answer, latency_ms, usage = call_cloud(messages, effective_temp)
            confidence = 1.0
            route = "cloud"
        except Exception as cloud_error:
            raise HTTPException(
                status_code=503,
                detail=f"Cloud model unavailable: {str(cloud_error)}"
            )
    else:
        try:
            parsed, local_ms, local_usage = try_local(messages, effective_temp, model=local_model)
            confidence = parsed.get("confidence", 0.0)
            answer = parsed.get("answer", "")
            usage = local_usage or {}
            latency_ms = local_ms
        except Exception as local_error:
            print(f"Local model failed: {local_error}")
            if settings.ANTHROPIC_API_KEY and cloud_allowed(messages):
                try:
                    answer, latency_ms, usage = call_cloud(messages, effective_temp)
                    confidence = 1.0
                    route = "cloud"
                except Exception as cloud_error:
                    raise HTTPException(
                        status_code=503,
                        detail=(
                            "Local model (Ollama) unavailable and cloud fallback failed. "
                            f"Ollama error: {str(local_error)} | "
                            f"Cloud error: {str(cloud_error)}"
                        )
                    )
            else:
                raise HTTPException(
                    status_code=503,
                    detail=f"Local model (Ollama) unavailable: {str(local_error)}. "
                           f"Make sure Ollama is running: 'ollama serve' and model is pulled: "
                           f"'ollama pull {local_model}'"
                )

        if route == "local" and confidence < settings.CONFIDENCE_THRESHOLD:
            if cloud_allowed(messages) and settings.ANTHROPIC_API_KEY:
                try:
                    txt, cloud_ms, cloud_usage = call_cloud(messages, effective_temp)
                    route = "cloud"
                    confidence = 1.0
                    answer = txt
                    usage = cloud_usage or {}
                    latency_ms = cloud_ms
                except Exception as cloud_error:
                    print(f"Cloud routing failed (confidence was {confidence:.2f}), using local answer: {str(cloud_error)}")
                    usage = local_usage or {}
                    latency_ms = local_ms
            else:
                usage = local_usage or {}
                latency_ms = local_ms
                if not settings.ANTHROPIC_API_KEY:
                    print(f"Low confidence ({confidence:.2f}) but no Anthropic key configured, using local answer anyway")
        elif route == "local":
            usage = local_usage or {}
            latency_ms = local_ms

    # Ensure we have a valid answer
    if not answer or not answer.strip():
        answer = "I apologize, but I couldn't generate a proper response. Please try rephrasing your question."
        confidence = 0.0
        print(f"Warning: Empty answer after routing. Route was: {route}")
    
    # Calculate costs
    est_cost = estimate_cost(usage) if route == "cloud" else 0.0
    # Naive saved cost: pretend same tokens would have gone to cloud
    est_saved = 0.0 if route == "cloud" else estimate_cost(local_usage)

    response_model_name = settings.CLOUD_MODEL if route == "cloud" else local_model
    response_local_model = None if force_cloud else local_model

    resp = ChatResponse(
        id=str(uuid.uuid4())[:8],
        choices=[Choice(index=0, message=ChoiceMsg(content=answer))],
        model=response_model_name,
        local_model=response_local_model,
        route=route,
        confidence=float(confidence),
        latency_ms=latency_ms,
        estimated_cost_usd=round(est_cost, 6),
        estimated_cost_saved_usd=round(est_saved, 6),
        usage=usage,
        conversation_id=conversation_id
    ).dict()

    # Persist log, cap size
    with SessionLocal() as db:
        le = LogEntry(
            route=route,
            prompt_hash=key,
            confidence=float(confidence),
            latency_ms=latency_ms,
            estimated_cost_usd=resp["estimated_cost_usd"],
            estimated_cost_saved_usd=resp["estimated_cost_saved_usd"],
            request=json.dumps({
                "conversation_id": conversation_id,
                "messages": [m for m in messages],
                "requested_model": requested_model or None,
                "selected_local_model": None if force_cloud else local_model,
                "forced_cloud": force_cloud
            }),
            response=json.dumps(resp)
        )
        db.add(le)
        db.commit()
        
        # Prune old logs
        db.execute(
            text(
                f"DELETE FROM logs WHERE id NOT IN "
                f"(SELECT id FROM logs ORDER BY id DESC LIMIT {settings.MAX_LOG_ROWS})"
            )
        )
        db.commit()

    # Cache the response
    cache_set(key, resp)

    return resp


@app.get("/api/logs")
def logs():
    """Get recent request logs for dashboard."""
    with SessionLocal() as db:
        rows = db.execute(
            text(
                "SELECT id, route, confidence, latency_ms, estimated_cost_usd, "
                "estimated_cost_saved_usd, created_at FROM logs ORDER BY id DESC LIMIT 100"
            )
        ).fetchall()
        return [dict(r._mapping) for r in rows]


@app.get("/")
def root():
    """Health check endpoint."""
    return {"status": "ok", "service": "local-first-router"}


@app.get("/api/config")
def config():
    """Expose router configuration for frontend."""
    # Only expose cloud model if API key is configured
    cloud_model = settings.CLOUD_MODEL if settings.ANTHROPIC_API_KEY else ""
    return {
        "local_models": settings.LOCAL_MODELS,
        "default_local_model": settings.LOCAL_MODEL,
        "cloud_model": cloud_model,
        "confidence_threshold": settings.CONFIDENCE_THRESHOLD,
    }

