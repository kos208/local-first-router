# Deterministic Web Search Design

## Current Problem
- Model must autonomously decide to request web search
- Model might miss obvious cases that need search
- Inconsistent behavior - sometimes searches, sometimes doesn't
- Relies on model understanding JSON format correctly

## Proposed Solution: Keyword-Based Deterministic Search

### Approach
1. **Pre-process user query** - Check for keywords/patterns BEFORE sending to model
2. **Automatic search trigger** - If keywords detected, perform search automatically
3. **Inject results** - Feed search results into prompt before model sees query
4. **Model just answers** - Model uses search results, doesn't need to request search

### Flow

```
User Query
    ↓
Keyword Detection (deterministic)
    ↓
    ├─→ No keywords → Send to model normally
    └─→ Keywords found → Perform search → Inject results → Send to model
    ↓
Model answers using search results
```

### Keyword Detection Rules

#### Time-sensitive keywords:
- "today", "yesterday", "recent", "latest", "current", "now"
- "this week", "this month", "this year"
- "2024", "2025" (recent years)
- "happened", "happening", "breaking"

#### News/information keywords:
- "news", "headlines", "breaking news"
- "developments", "updates", "announcements"
- "who won", "what happened", "current events"

#### Search action keywords:
- "search for", "look up", "find information"
- "what is the current", "what are the latest"

#### Query patterns:
- Questions with dates: "What happened on [date]?"
- Questions with "today"/"recent": "What happened today?"
- Questions with "news": "What are the news?"

### Implementation Plan

1. **Enhance detection function** - Make it more comprehensive
2. **Add automatic search in router** - Check keywords before calling model
3. **Inject results as system message** - Put search results in context
4. **Simplify system prompt** - Remove search request instructions (model just answers)
5. **Add config flag** - Allow users to enable/disable auto-search

### Benefits

✅ **Reliable** - Always searches when keywords detected
✅ **Fast** - No need to wait for model to request search
✅ **Simple** - Model doesn't need to understand search requests
✅ **Consistent** - Same queries always trigger search
✅ **Transparent** - Can show in UI that search was performed

### Configuration

Add to settings:
- `AUTO_WEB_SEARCH`: bool (default: true)
- `WEB_SEARCH_KEYWORDS`: List[str] (customizable keywords)
- `FORCE_WEB_SEARCH_PATTERNS`: List[str] (regex patterns that always trigger)

### Edge Cases

- **False positives**: "What is the history of today's date?" - doesn't need current info
  - Solution: Context-aware detection (ignore if asking about past dates)
  
- **Missed cases**: "Tell me about Tesla" - might need recent info
  - Solution: Model can still request search (hybrid approach)
  
- **Multiple searches**: Complex query needing multiple searches
  - Solution: Extract multiple search queries from complex questions

### Hybrid Approach (Optional)

Keep both:
1. **Automatic search** for obvious cases (deterministic)
2. **Model-requested search** for edge cases (still allows model autonomy)

Best of both worlds!

