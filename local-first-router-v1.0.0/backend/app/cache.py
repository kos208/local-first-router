import hashlib
import time
from typing import Optional

_cache = {}


def key_for_messages(messages: list[dict], model_hint: str = "") -> str:
    """Generate a cache key from messages and optional model hint."""
    prefix = f"{model_hint}\n" if model_hint else ""
    s = prefix + "\n".join([f"{m.get('role', '')}|{m.get('content', '')}" for m in messages])
    return hashlib.sha256(s.encode()).hexdigest()


def cache_get(k: str, ttl: int) -> Optional[dict]:
    """Get cached value if not expired."""
    item = _cache.get(k)
    if not item:
        return None
    if time.time() - item["ts"] > ttl:
        _cache.pop(k, None)
        return None
    return item["val"]


def cache_set(k: str, val: dict):
    """Set a value in cache with current timestamp."""
    _cache[k] = {"ts": time.time(), "val": val}

