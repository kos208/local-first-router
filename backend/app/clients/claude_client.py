from typing import List, Tuple, Optional

import requests
from requests import HTTPError

from ..settings import settings

ANTHROPIC_VERSION = "2023-06-01"


def _convert_messages(messages: List[dict]) -> Tuple[Optional[str], List[dict]]:
    """Convert OpenAI-style messages to Anthropic's message format."""
    system_prompts: List[str] = []
    converted: List[dict] = []

    for msg in messages:
        role = msg.get("role", "user")
        content = msg.get("content", "")

        if role == "system":
            system_prompts.append(str(content))
            continue

        anth_role = role if role in {"user", "assistant"} else "user"
        converted.append(
            {
                "role": anth_role,
                "content": [
                    {
                        "type": "text",
                        "text": str(content)
                    }
                ],
            }
        )

    system_prompt = "\n\n".join(system_prompts) if system_prompts else None
    return system_prompt, converted


def chat(messages, model=None, temperature=0.2, max_tokens: Optional[int] = None, tools=None):
    """Call Anthropic Claude messages endpoint and return OpenAI-compatible shape."""
    if not settings.ANTHROPIC_API_KEY:
        raise RuntimeError("Anthropic API key is not configured.")

    system_prompt, converted_messages = _convert_messages(messages)

    payload = {
        "model": model or settings.CLOUD_MODEL,
        "messages": converted_messages,
        "temperature": temperature,
        "max_tokens": max_tokens or settings.CLOUD_MAX_TOKENS or 1024,
    }

    if system_prompt:
        payload["system"] = system_prompt
    
    # Add tools if provided
    if tools:
        payload["tools"] = tools

    try:
        response = _post_messages(payload)
        data = response.json()
        return _parse_messages_response(data)
    except HTTPError as exc:
        if exc.response is not None and exc.response.status_code == 404:
            # Older accounts may not have the Messages API enabled yet.
            return _call_complete(messages, system_prompt, model, temperature, max_tokens)
        raise


def _post_messages(payload: dict):
    response = requests.post(
        f"{settings.ANTHROPIC_BASE}/v1/messages",
        headers=_build_headers(),
        json=payload,
        timeout=90,
    )
    response.raise_for_status()
    return response


def _parse_messages_response(data: dict):
    text_blocks = [
        block.get("text", "")
        for block in data.get("content", [])
        if block.get("type") == "text"
    ]
    combined_text = "\n".join(filter(None, text_blocks)).strip()

    usage_raw = data.get("usage", {}) or {}
    prompt_tokens = usage_raw.get("input_tokens") or 0
    completion_tokens = usage_raw.get("output_tokens") or 0
    total_tokens = (
        prompt_tokens + completion_tokens
        if (prompt_tokens or completion_tokens)
        else None
    )

    usage = {
        "prompt_tokens": prompt_tokens,
        "completion_tokens": completion_tokens,
        "total_tokens": total_tokens,
    }

    return {
        "choices": [
            {
                "message": {
                    "content": combined_text,
                }
            }
        ],
        "usage": usage,
    }


def _messages_to_prompt(messages: List[dict], system_prompt: Optional[str]) -> str:
    sections: List[str] = []
    if system_prompt:
        sections.append(f"\n\nHuman: {system_prompt.strip()}")
        sections.append("\n\nAssistant:")

    for msg in messages:
        role = msg.get("role", "user")
        content = (msg.get("content") or "").strip()
        if not content:
            continue
        if role == "assistant":
            sections.append(f"\n\nAssistant: {content}")
        else:
            sections.append(f"\n\nHuman: {content}")

    if not sections or not sections[-1].startswith("\n\nAssistant:"):
        sections.append("\n\nAssistant:")

    return "".join(sections)


def _call_complete(messages, system_prompt, model, temperature, max_tokens):
    prompt = _messages_to_prompt(messages, system_prompt)
    payload = {
        "model": model or settings.CLOUD_MODEL,
        "prompt": prompt,
        "temperature": temperature,
        "max_tokens_to_sample": max_tokens or settings.CLOUD_MAX_TOKENS or 1024,
        "stop_sequences": ["\n\nHuman:"],
    }

    try:
        response = requests.post(
            f"{settings.ANTHROPIC_BASE}/v1/complete",
            headers=_build_headers(),
            json=payload,
            timeout=90,
        )
        response.raise_for_status()
    except HTTPError as exc:
        if exc.response is not None and exc.response.status_code == 404:
            raise RuntimeError(
                "Anthropic API returned 404 for both Messages and Complete endpoints. "
                "If you're using a preview model, set ANTHROPIC_BETA with the required beta flag."
            ) from exc
        raise

    data = response.json()

    completion_text = data.get("completion", "").strip()

    usage_raw = data.get("usage", {}) or {}
    prompt_tokens = usage_raw.get("input_tokens") or 0
    completion_tokens = usage_raw.get("output_tokens") or 0
    total_tokens = (
        prompt_tokens + completion_tokens
        if (prompt_tokens or completion_tokens)
        else None
    )

    usage = {
        "prompt_tokens": prompt_tokens,
        "completion_tokens": completion_tokens,
        "total_tokens": total_tokens,
    }

    return {
        "choices": [
            {
                "message": {
                    "content": completion_text,
                }
            }
        ],
        "usage": usage,
    }


def _build_headers():
    headers = {
        "x-api-key": settings.ANTHROPIC_API_KEY,
        "content-type": "application/json",
        "anthropic-version": ANTHROPIC_VERSION,
    }
    if settings.ANTHROPIC_BETA:
        headers["anthropic-beta"] = settings.ANTHROPIC_BETA
    return headers

