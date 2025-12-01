# Web Search Feature

## Overview

The router now supports web search capabilities for both local and cloud models, allowing them to access real-time information from the internet when needed.

## How It Works

### Detection

The system automatically detects when a query likely needs web search by looking for:
- Time-sensitive keywords ("today", "recent", "latest", "current", "now")
- Search action keywords ("search for", "look up", "find information")
- Current event questions ("what happened", "news", "who won")

### Implementation

#### For Local Models
1. System detects if web search is needed
2. Performs web search using DuckDuckGo (free, no API key)
3. Injects search results into the prompt as context
4. Local model uses results to answer

#### For Cloud (Claude)
1. System detects if web search is needed
2. Performs web search using DuckDuckGo
3. Adds search results as system context
4. Claude uses results in response

## Configuration

In `.env`:

```bash
# Enable/disable web search
ENABLE_WEB_SEARCH=true

# Maximum number of search results to include
WEB_SEARCH_MAX_RESULTS=5
```

## Privacy

- Uses DuckDuckGo (privacy-focused search engine)
- No API keys required
- No tracking or logging of search queries
- Can be disabled via settings

## Usage Examples

### Examples that trigger web search:
- "What happened in the news today?"
- "What are the latest developments in AI?"
- "Who won the game yesterday?"
- "What's the current weather in New York?"

### Examples that don't trigger:
- "What is quantum computing?" (general knowledge)
- "Explain how photosynthesis works" (scientific fact)
- "What is 2+2?" (mathematical)

## Future Enhancements

- Full Claude tool/function calling support (native tool use)
- Configurable search engines
- Search result caching
- More sophisticated detection
- UI indicator when web search is used

## Limitations

- DuckDuckGo rate limits may apply with heavy use
- Search results depend on DuckDuckGo availability
- Detection is heuristic-based (may miss some cases)
- Local models get search results injected; Claude gets enhanced prompts

## Testing

Try queries like:
- "What's the latest news about AI?"
- "What happened today in tech?"
- "Who won the championship recently?"

The system should automatically perform web searches and use the results to answer.

