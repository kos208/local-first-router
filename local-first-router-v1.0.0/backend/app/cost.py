from .settings import settings


def estimate_cost(usage: dict) -> float:
    """Estimate cost based on token usage and configured pricing."""
    # usage may carry token counts from providers; if not, guess zero
    in_tok = usage.get("prompt_tokens", 0)
    out_tok = usage.get("completion_tokens", 0)
    return (in_tok / 1000.0) * settings.PRICE_PER_1K_INPUT + (out_tok / 1000.0) * settings.PRICE_PER_1K_OUTPUT

