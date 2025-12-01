# Web Search Output Format - What the Model Sees

## Overview

When web search is performed, the model receives search results in a specific format. Here's exactly what it looks like:

## Full System Message Format

The model sees the search results wrapped in a system message like this:

```
Web search was performed to get current and relevant information. Here are the search results:

[FORMATTED SEARCH RESULTS HERE]

Use this information to provide an accurate, up-to-date answer to the user's question. If the search results don't contain relevant information for the question, you can still answer based on your knowledge.
```

## Search Results Format

The formatted search results look like this:

```
Web search results for 'latest AI developments':

1. 7 major AI updates this week - Tom's Guide
   URL: https://www.tomsguide.com/ai/7-major-ai-updates-this-week...
   Missed the latest AI news? From ChatGPT upgrades to Google's new tools, here are 7 big AI updates you need to know about this week.

2. Google News - Artificial intelligence - Latest
   URL: https://news.google.com/topics/CAAqJAgKIh5DQkFTRUFvSEwyMHZNRzFyZWhJRlpXNHRSMElvQUFQAQ
   Read full articles, watch videos, browse thousands of titles and more on the "Artificial intelligence" topic with Google News.

3. Top 10 Artificial Intelligence Technology Trends in 2025
   URL: https://www.cognitivetoday.com/2025/11/top-10-artificial-intelligence-technology-trends-in-2025/
   From autonomous agents to quantum computing, the AI trends of 2025 are set to push the boundaries of what's possible...
```

## Structure

Each search result includes:
1. **Number**: Sequential number (1, 2, 3...)
2. **Title**: Article/page title
3. **URL**: Source URL (if available)
4. **Snippet**: Brief text excerpt (up to 300 characters)

## Example: Complete Message Chain

Here's what the model receives:

### System Prompt (CONF_SYS)
```
You are an expert assistant.
OUTPUT FORMAT (MANDATORY):
...
```

### Web Search Results (System Message)
```
Web search was performed to get current and relevant information. Here are the search results:

Web search results for 'latest AI developments':

1. 7 major AI updates this week - Tom's Guide
   URL: https://www.tomsguide.com/...
   Missed the latest AI news? From ChatGPT upgrades...

2. Google News - Artificial intelligence - Latest
   URL: https://news.google.com/...
   Read full articles, watch videos...

Use this information to provide an accurate, up-to-date answer to the user's question. If the search results don't contain relevant information for the question, you can still answer based on your knowledge.
```

### User Message
```
What are the latest AI developments?
```

## Configuration

- **Max Results**: Controlled by `WEB_SEARCH_MAX_RESULTS` (default: 5)
- **Format**: Fixed format - always shows title, URL, and snippet
- **Length**: Each snippet is truncated to ~300 characters

## Current Behavior

With "always-on" web search enabled:
- **Every query** gets search results
- Results are **always** injected before the user's question
- Model is instructed to use the results but can fall back to its knowledge

## Sample Output

For query: "latest AI developments"

```
Web search results for 'latest AI developments':

1. 7 major AI updates this week - Tom's Guide
   URL: https://www.tomsguide.com/ai/7-major-ai-updates-this-week...
   Missed the latest AI news? From ChatGPT upgrades to Google's new tools, here are 7 big AI updates you need to know about this week.

2. Google News - Artificial intelligence - Latest
   URL: https://news.google.com/topics/...
   Read full articles, watch videos, browse thousands of titles and more on the "Artificial intelligence" topic with Google News.

3. Top 10 Artificial Intelligence Technology Trends in 2025
   URL: https://www.cognitivetoday.com/2025/11/top-10-artificial-intelligence-technology-trends-in-2025/
   From autonomous agents to quantum computing, the AI trends of 2025 are set to push the boundaries...
```

The model sees this formatted text and uses it to provide answers with current information.

