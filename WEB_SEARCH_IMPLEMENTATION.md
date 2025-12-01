# Web Search Implementation Plan

## Overview

Adding web search capabilities to both local and cloud models, allowing them to access real-time information from the internet when needed.

## Approach

### For Local Models
- **Detection:** Analyze query to determine if web search is needed
- **Enhancement:** Perform web search and inject results into the prompt
- **Response:** Local model uses search results to provide up-to-date answers

### For Claude (Cloud)
- **Tool Use:** Use Claude's tool/function calling API
- **Native Support:** Claude can decide when to use web search
- **Better Integration:** More seamless experience

## Implementation Steps

1. ✅ Create web search service (DuckDuckGo-based, no API key)
2. 🔄 Add web search detection logic
3. 🔄 Integrate into local model flow
4. 🔄 Add Claude tool/function calling support
5. 🔄 Update settings to enable/disable web search
6. 🔄 Update UI to show when web search is used

## Usage

Users can:
- Ask questions requiring current information
- Get real-time data without manual searching
- Use both local and cloud models with web search

## Privacy

- Web search queries are sent to DuckDuckGo (privacy-focused)
- No tracking or logging of search queries
- Users can disable web search if desired

