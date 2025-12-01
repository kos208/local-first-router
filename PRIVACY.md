# Privacy & Data Sharing

## Important Privacy Information

### When Fallback to Claude Occurs

**YES - The entire conversation history is sent to Claude (Anthropic) when fallback happens.**

### What Gets Sent

When the router falls back to Claude (cloud), it sends:

1. **All previous messages** in the conversation (user + assistant)
2. **The current message** being processed
3. **Any system prompts** included in the conversation

### How It Works

```
User: "Hello"
Assistant: "Hi there!"

User: "What is quantum computing?"  ← If local confidence < 0.7, fallback happens

→ Router sends ALL 3 messages to Claude:
  1. User: "Hello"
  2. Assistant: "Hi there!"
  3. User: "What is quantum computing?"
```

### When Fallback Happens

Fallback to Claude occurs when:
1. **Low confidence:** Local model confidence < 70% (default threshold)
2. **Local model failure:** Ollama is unavailable or errors
3. **Manual selection:** User explicitly chooses "Cloud" model

### Privacy Controls

#### Option 1: Use `#no_cloud` Tag

Add `#no_cloud` to any message to **force local-only processing**:

```
User: "My password is secret123 #no_cloud"
```

This prevents ANY cloud routing, even if confidence is low.

#### Option 2: Disable Cloud Fallback

In your `.env` file:
```bash
# Don't set ANTHROPIC_API_KEY, or set it to empty
# ANTHROPIC_API_KEY=
```

Without an API key, the router will:
- ✅ Always use local model
- ✅ Never send data to cloud
- ⚠️ Fail if local model has issues (no fallback)

#### Option 3: Adjust Confidence Threshold

Make the threshold higher so less fallback occurs:
```bash
CONFIDENCE_THRESHOLD=0.5  # Lower = more local, less cloud
```

### What Data is NOT Sent to Claude

When using local model only:
- ❌ Nothing is sent to Claude
- ✅ All processing happens locally
- ✅ Complete privacy

### What Data IS Sent to Claude

When fallback occurs:
- ✅ Entire conversation history
- ✅ Current message
- ✅ System prompts (if any)

**This data goes to:**
- Anthropic's Claude API servers
- Subject to Anthropic's privacy policy
- May be used for training (check Anthropic's terms)

### Recommendations for Privacy

1. **For sensitive conversations:**
   - Always use `#no_cloud` tag
   - Or disable cloud fallback entirely

2. **For general use:**
   - Default behavior is fine
   - Local-first means most requests stay local
   - Only complex/uncertain queries go to cloud

3. **For maximum privacy:**
   - Don't configure `ANTHROPIC_API_KEY`
   - Router will only use local model
   - No data leaves your machine

### Technical Details

The conversation history is sent because:
- LLMs need context to provide coherent responses
- Claude needs to understand the conversation flow
- This is standard behavior for chat APIs

**The router does NOT:**
- Store conversations on external servers
- Share data with third parties
- Log conversations externally (only local SQLite)

**The router DOES:**
- Log locally (SQLite database)
- Cache responses locally
- Send full context to Claude when routing (for quality)

### Checking What Was Sent

You can check the logs to see what was routed to cloud:

1. Open the "Request Logs" tab in the UI
2. Look for `route: "cloud"` entries
3. These indicate when Claude was used

### Summary

- **Local model:** Complete privacy, nothing sent externally
- **Cloud fallback:** Full conversation history sent to Anthropic
- **Control:** Use `#no_cloud` tag or disable API key for privacy

