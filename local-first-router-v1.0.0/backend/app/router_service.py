import json
import re
import time
from .settings import settings
from .clients import ollama_client, claude_client
from .policy import cloud_allowed
from .cache import key_for_messages, cache_get, cache_set

CONF_SYS = {
    "role": "system",
    "content": (
        "You are an expert assistant. Respond strictly as JSON: {\"answer\": \"...\", \"confidence\": number between 0 and 1}.\n"
        "Confidence = the probability that a domain expert would judge the answer correct.\n"
        "Produce thorough, multi-paragraph answers that leverage prior conversation context when helpful.\n"
        "Include step-by-step reasoning, examples, and relevant caveats when appropriate.\n"
        "For mathematical expressions, use LaTeX with dollar signs:\n"
        "- Inline math: $expression$ (e.g., $x^2 + y^2$)\n"
        "- Display math: $$expression$$ (e.g., $$\\frac{a}{b}$$)\n"
        "Example JSON: {\"answer\": \"The quadratic formula is $x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}$.\", \"confidence\": 0.9}"
    )
}


def parse_json_block(text: str):
    """Extract JSON from model response, handling various formats."""
    m = re.search(r"\{.*\}", text, re.S)
    if not m:
        return {"answer": text.strip(), "confidence": 0.0}
    block = m.group(0)
    try:
        obj = json.loads(block)
        return {
            "answer": obj.get("answer", "").strip(),
            "confidence": float(obj.get("confidence", 0))
        }
    except Exception:
        # Attempt a lenient parse when JSON is slightly malformed (e.g. single backslashes)
        answer = ""
        confidence = 0.0
        ans_match = re.search(r'"answer"\s*:\s*"(.*?)"\s*(,|})', block, re.S)
        if ans_match:
            raw_answer = ans_match.group(1)
            try:
                answer = bytes(raw_answer, "utf-8").decode("unicode_escape")
            except Exception:
                answer = raw_answer
            answer = answer.replace("\\\"", "\"").strip()
        conf_match = re.search(r'"confidence"\s*:\s*([0-9]+\.?[0-9]*)', block)
        if conf_match:
            try:
                confidence = float(conf_match.group(1))
            except ValueError:
                confidence = 0.0
        if not answer:
            answer = text.strip()
        return {"answer": answer, "confidence": confidence}


def try_local(messages, temperature=None, model=None):
    """Try local model with confidence-aware system prompt."""
    start = time.time()
    temp = temperature if temperature is not None else settings.LOCAL_TEMPERATURE
    max_tokens = settings.LOCAL_MAX_TOKENS
    try:
        res = ollama_client.chat(
            messages=[CONF_SYS] + messages,
            temperature=temp,
            max_tokens=max_tokens,
            model=model or settings.LOCAL_MODEL
        )
        txt = res["choices"][0]["message"]["content"]
        print(f"Local model response: {txt[:200]}...")  # Debug log
        parsed = parse_json_block(txt)
        latency = int((time.time() - start) * 1000)
        usage = res.get("usage", {})
        print(f"Parsed: answer length={len(parsed.get('answer', ''))}, confidence={parsed.get('confidence')}")
        return parsed, latency, usage
    except Exception as e:
        print(f"Error in try_local: {str(e)}")
        raise


def call_cloud(messages, temperature=None):
    """Call cloud model."""
    start = time.time()
    temp = temperature if temperature is not None else 0.2
    res = claude_client.chat(
        messages=messages,
        temperature=temp,
        max_tokens=settings.CLOUD_MAX_TOKENS,
    )
    txt = res["choices"][0]["message"]["content"]
    latency = int((time.time() - start) * 1000)
    usage = res.get("usage", {})
    return txt, latency, usage

