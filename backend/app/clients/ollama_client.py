import requests
from requests import HTTPError
from typing import List

from ..settings import settings


def chat(messages, model=None, temperature=0.2, max_tokens=None):
    """Call Ollama and normalize response. Falls back for older servers."""
    payload = _build_chat_payload(messages, model, temperature, max_tokens)

    try:
        data = _post_chat(payload)
    except HTTPError as exc:
        if exc.response is not None and exc.response.status_code == 404:
            data = _post_generate(messages, model, temperature, max_tokens)
        else:
            raise

    return _normalize_usage(data)


def _build_chat_payload(messages, model, temperature, max_tokens):
    payload = {
        "model": model or settings.LOCAL_MODEL,
        "messages": messages,
        "stream": False,
    }
    options = {}
    if temperature is not None:
        options["temperature"] = temperature
    if max_tokens is not None:
        options["num_predict"] = max_tokens
    if options:
        payload["options"] = options
    return payload


def _post_chat(payload):
    r = requests.post(
        f"{settings.OLLAMA_BASE}/api/chat",
        json=payload,
        timeout=120,
    )
    r.raise_for_status()
    return r.json()


def _post_generate(messages, model, temperature, max_tokens):
    prompt = _messages_to_prompt(messages)
    payload = {
        "model": model or settings.LOCAL_MODEL,
        "prompt": prompt,
        "stream": False,
    }
    options = {}
    if temperature is not None:
        options["temperature"] = temperature
    if max_tokens is not None:
        options["num_predict"] = max_tokens
    if options:
        payload["options"] = options

    r = requests.post(
        f"{settings.OLLAMA_BASE}/api/generate",
        json=payload,
        timeout=120,
    )
    r.raise_for_status()
    data = r.json()

    content = data.get("response", "")
    prompt_tokens = data.get("prompt_eval_count")
    completion_tokens = data.get("eval_count")

    return {
        "message": {"content": content},
        "prompt_eval_count": prompt_tokens,
        "eval_count": completion_tokens,
    }


def _messages_to_prompt(messages):
    lines: List[str] = []
    for msg in messages:
        role = msg.get("role", "user").capitalize()
        content = msg.get("content", "")
        lines.append(f"{role}: {content}")
    lines.append("Assistant:")
    return "\n\n".join(lines)


def _normalize_usage(data):
    message = data.get("message", {})
    content = message.get("content", "")

    prompt_tokens = data.get("prompt_eval_count")
    completion_tokens = data.get("eval_count")
    total_tokens = None
    if prompt_tokens is not None and completion_tokens is not None:
        total_tokens = prompt_tokens + completion_tokens

    return {
        "choices": [
            {
                "message": {
                    "content": content,
                }
            }
        ],
        "usage": {
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "total_tokens": total_tokens,
        },
    }

