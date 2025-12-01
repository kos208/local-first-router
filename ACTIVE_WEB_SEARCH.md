# Active Web Search Feature

## Overview

The local model can now **actively request** web searches when it determines it needs current information, rather than just receiving them automatically.

## How It Works

### 1. Model Can Request Search

The model responds with JSON that includes:
```json
{
  "answer": "...",
  "confidence": 0.5,
  "needs_web_search": true,
  "search_query": "latest AI developments 2024"
}
```

### 2. Search Loop Process

1. **First Request:** Model analyzes the query
2. **Model Decision:** If it needs current info, sets `needs_web_search: true` with a `search_query`
3. **Router Action:** Router performs the web search
4. **Results Injected:** Search results are provided to the model
5. **Final Answer:** Model generates answer using search results

This can happen in a loop (up to 3 iterations) until the model provides a final answer.

## Example Flow

**User asks:** "What happened in tech news today?"

**Iteration 1:**
- Model responds: `{"needs_web_search": true, "search_query": "tech news today"}`
- Router performs search and gets results
- Router provides results back to model

**Iteration 2:**
- Model receives search results
- Model responds with final answer using the search results

## JSON Response Format

The model now responds with:
```json
{
  "answer": "The answer text...",
  "confidence": 0.0-1.0,
  "needs_web_search": true/false,
  "search_query": "query to search for"  // Only if needs_web_search is true
}
```

## System Prompt

The model is told in the system prompt:
- It can request web searches for current information
- How to format the request (`needs_web_search: true`, `search_query: "..."`)
- When to use it (current events, real-time data, recent news)

## Benefits

1. **Model-driven:** Model decides when search is needed
2. **Flexible:** Can handle queries that don't obviously need search
3. **Iterative:** Can refine search queries based on results
4. **Automatic:** No manual intervention needed

## Configuration

Same as before in `.env`:
```bash
ENABLE_WEB_SEARCH=true
WEB_SEARCH_MAX_RESULTS=5
```

## Comparison

### Before (Automatic Detection)
- Router automatically detects search need
- Model just receives results
- Less flexible

### Now (Active Request)
- Model actively requests searches
- More intelligent decision making
- Can refine queries iteratively

Both methods work together - automatic detection still happens, but model can also request searches.

## Testing

Try asking:
- "What are the latest developments in AI?"
- "Who won the championship recently?"
- "What happened in the stock market today?"

The model should actively request web searches when it needs current information.

