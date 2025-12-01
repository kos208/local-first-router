# How Web Search Currently Works

## Current Implementation

### Flow for Local Model

1. **User sends a query** → Router receives it
2. **Router calls local model** with system prompt (tells model it can request searches)
3. **Model responds in JSON:**
   ```json
   {
     "answer": "...",
     "confidence": 0.5,
     "needs_web_search": true,
     "search_query": "latest AI news"
   }
   ```
4. **Router checks response:**
   - If `needs_web_search: true` → Router performs the search
   - Router injects search results back into conversation
   - Router asks model again with search results
5. **Model receives search results** and provides final answer

### Current Limitations

- **Model can request search** ✅ (via JSON response)
- **Search happens automatically** ✅ (router performs it)
- **Model gets results** ✅ (injected into conversation)

**However:**
- The search loop happens on the backend (hidden from user)
- User sees the final answer, not the intermediate search step
- Search happens in a loop (up to 3 iterations)

## What "Direct Web Query" Means

The model **CAN** query the web directly by:
1. Setting `needs_web_search: true` in its JSON response
2. Providing a `search_query`
3. Router automatically performs the search
4. Results are fed back to the model

**This IS direct web query** - the model decides when to search and what to search for.

## Alternative: Full Tool Calling (Like Claude)

For even more direct control, we could implement:
- Ollama tool/function calling (if supported)
- Model requests tool execution
- More explicit tool responses

But the current implementation already allows the model to request searches directly via the JSON format.

## Summary

**Current:** Model can request web searches via JSON (`needs_web_search: true`) → Router performs search → Results fed back to model → Model answers

**This IS direct web query** - the model controls when and what to search for.

