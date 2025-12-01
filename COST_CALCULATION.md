# Cost Calculation Explained

## How Claude API Pricing Works

### Answer: **BOTH Input + Output Tokens**

Claude API charges for:
1. **Input tokens** (your prompt + conversation history) - Lower rate
2. **Output tokens** (Claude's response) - Higher rate

**Total Cost = (Input Tokens × Input Rate) + (Output Tokens × Output Rate)**

---

## Current Calculation in Router

```python
def estimate_cost(usage: dict) -> float:
    in_tok = usage.get("prompt_tokens", 0)
    out_tok = usage.get("completion_tokens", 0)
    return (in_tok / 1000.0) * PRICE_PER_1K_INPUT + (out_tok / 1000.0) * PRICE_PER_1K_OUTPUT
```

This correctly calculates:
- Cost for input tokens (your messages)
- Cost for output tokens (Claude's response)
- Sums them together

---

## Current Pricing Settings

From `settings.py`:

```python
PRICE_PER_1K_INPUT: float = 0.005   # $0.005 per 1,000 input tokens
PRICE_PER_1K_OUTPUT: float = 0.015  # $0.015 per 1,000 output tokens
```

### Example Calculation

If a request uses:
- **500 input tokens** (your messages)
- **300 output tokens** (Claude's response)

Cost = (500 / 1000) × $0.005 + (300 / 1000) × $0.015
     = $0.0025 + $0.0045
     = **$0.007**

---

## Claude 3 Haiku Pricing (Current Model)

According to Anthropic's official pricing:

**Claude 3 Haiku:**
- Input: **$0.25 per 1M tokens** = **$0.00025 per 1K tokens**
- Output: **$1.25 per 1M tokens** = **$0.00125 per 1K tokens**

**Note:** Your current settings are higher than actual Haiku pricing:
- Your settings: $0.005 input / $0.015 output
- Actual Haiku: $0.00025 input / $0.00125 output

This means your cost estimates are **higher than actual costs** (safer for budgeting).

---

## Token Counts

### Input Tokens Include:
- All previous messages in conversation
- Current user message
- System prompts (if any)
- API overhead/formatting

### Output Tokens Include:
- Claude's complete response
- Any formatting/structured output

---

## Real Example

From an earlier test:
```json
{
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 88,
    "total_tokens": 100
  },
  "estimated_cost_usd": 0.00138
}
```

Calculation with current settings:
- Input: (12 / 1000) × $0.005 = $0.00006
- Output: (88 / 1000) × $0.015 = $0.00132
- **Total: $0.00138** ✅

With actual Haiku pricing:
- Input: (12 / 1000) × $0.00025 = $0.000003
- Output: (88 / 1000) × $0.00125 = $0.00011
- **Total: $0.000113** (actual cost)

---

## Why Output Costs More

- **Input tokens:** Claude just reads them
- **Output tokens:** Claude generates them (more compute-intensive)

Typical ratio: Output is 3-5× more expensive than input.

---

## Updating Pricing

If you want to use accurate Haiku pricing, update `.env`:

```bash
PRICE_PER_1K_INPUT=0.00025
PRICE_PER_1K_OUTPUT=0.00125
```

Or for other models:

### Claude 3 Sonnet
- Input: $0.003 per 1K tokens
- Output: $0.015 per 1K tokens

### Claude 3 Opus
- Input: $0.015 per 1K tokens
- Output: $0.075 per 1K tokens

---

## Summary

✅ **Cost = Input Tokens + Output Tokens**  
✅ Both are charged separately at different rates  
✅ Output tokens cost more than input tokens  
✅ Your router calculates this correctly  
✅ Current settings overestimate (safer for budgeting)

---

## References

- Official Anthropic Pricing: https://docs.anthropic.com/claude/docs/pricing
- Check pricing for your specific model and region

