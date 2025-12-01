# Always-On Web Search Implementation

## What Changed

Web search now runs **for every query** automatically, regardless of keywords.

## Implementation

### Before
- Keyword detection → Only search if keywords found
- Some queries missed web search

### Now
- **Always perform web search** for every user query
- Search results always injected into prompt
- Model always has web information available

## Flow

```
User Query
    ↓
Always Perform Web Search
    ↓
Inject Search Results
    ↓
Send to Model
    ↓
Model Answers (with search results)
```

## Benefits

✅ **Consistent** - Every query gets web search
✅ **Comprehensive** - Model always has current web information
✅ **Reliable** - No missed searches
✅ **Simple** - No keyword detection needed

## Behavior

- **Every query** triggers web search automatically
- Search results are injected as system message
- Model uses search results to provide answers
- If search returns no results, model proceeds with its knowledge

## Configuration

Still controlled by:
- `ENABLE_WEB_SEARCH`: true/false (enable/disable web search)
- `WEB_SEARCH_MAX_RESULTS`: Number of results to fetch

If `ENABLE_WEB_SEARCH=false`, no search is performed.

## Performance

- Adds ~1-3 seconds per query (search time)
- More comprehensive answers
- Always up-to-date information

