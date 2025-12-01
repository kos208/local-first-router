"""
Web search service using DuckDuckGo (free, no API key required).
Provides web search functionality for both local and cloud models.
"""

import requests
from typing import List, Dict, Optional
import time

try:
    from ddgs import DDGS
    DDGS_AVAILABLE = True
except ImportError:
    try:
        from duckduckgo_search import DDGS
        DDGS_AVAILABLE = True
    except ImportError:
        DDGS_AVAILABLE = False
        print("Warning: ddgs not installed. Using fallback search method.")
        print("Install with: pip install ddgs")


class WebSearchService:
    """Web search service using DuckDuckGo search library."""
    
    def __init__(self):
        self.agent = "local-first-router/1.0"
        self.ddgs_available = DDGS_AVAILABLE
    
    def search(self, query: str, max_results: int = 5) -> List[Dict[str, str]]:
        """
        Perform a web search and return results.
        
        Args:
            query: Search query
            max_results: Maximum number of results to return
            
        Returns:
            List of dictionaries with 'title', 'url', 'snippet' keys
        """
        try:
            # Use duckduckgo-search library if available (better results)
            if self.ddgs_available:
                results = self._ddgs_search(query, max_results)
                if results:
                    return results
            
            # Fallback to HTML scraping
            results = self._html_search(query, max_results)
            if results:
                return results
            
            # Last resort: return search link
            return [{
                "title": f"Search: {query}",
                "url": f"https://duckduckgo.com/?q={query.replace(' ', '+')}",
                "snippet": f"Search performed for '{query}'. Visit the URL for results."
            }]
        except Exception as e:
            print(f"Web search error: {e}")
            import traceback
            traceback.print_exc()
            return []
    
    def _ddgs_search(self, query: str, max_results: int) -> List[Dict[str, str]]:
        """Search using duckduckgo-search library (best method)."""
        try:
            with DDGS() as ddgs:
                results = []
                for r in ddgs.text(query, max_results=max_results):
                    results.append({
                        "title": r.get("title", ""),
                        "url": r.get("href", ""),
                        "snippet": r.get("body", "")[:300]
                    })
                    if len(results) >= max_results:
                        break
                return results
        except Exception as e:
            print(f"DDGS search error: {e}")
            return []
    
    def _html_search(self, query: str, max_results: int) -> List[Dict[str, str]]:
        """Fallback HTML search method."""
        try:
            # Simple search using DuckDuckGo HTML interface
            url = "https://html.duckduckgo.com/html/"
            params = {"q": query}
            headers = {
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
            }
            
            response = requests.get(url, params=params, headers=headers, timeout=10)
            response.raise_for_status()
            
            # Simple parsing (basic extraction)
            parser = SimpleResultParser()
            parser.feed(response.text)
            
            return parser.results[:max_results]
        except Exception as e:
            print(f"HTML search error: {e}")
            return []
    
    def format_results_for_prompt(self, query: str, results: List[Dict[str, str]]) -> str:
        """Format search results for inclusion in a prompt."""
        if not results:
            return f"No web search results found for: {query}"
        
        formatted = f"Web search results for '{query}':\n\n"
        for i, result in enumerate(results, 1):
            title = result.get("title", "No title")
            url = result.get("url", "")
            snippet = result.get("snippet", "")
            formatted += f"{i}. {title}\n"
            if url:
                formatted += f"   URL: {url}\n"
            if snippet:
                formatted += f"   {snippet}\n"
            formatted += "\n"
        
        return formatted




# Global instance
_web_search_service: Optional[WebSearchService] = None


def get_web_search_service() -> WebSearchService:
    """Get or create web search service instance."""
    global _web_search_service
    if _web_search_service is None:
        _web_search_service = WebSearchService()
    return _web_search_service


from html.parser import HTMLParser

class SimpleResultParser(HTMLParser):
    """Simple HTML parser for DuckDuckGo results."""
    def __init__(self):
        super().__init__()
        self.results = []
        self.current_result = {}
        self.in_result = False
        self.in_title = False
        self.in_snippet = False
        
    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        if tag == "a" and "result__a" in attrs_dict.get("class", ""):
            self.in_title = True
            self.in_result = True
            href = attrs_dict.get("href", "")
            # Clean up DuckDuckGo redirect URLs
            if "uddg=" in href:
                import urllib.parse
                parsed = urllib.parse.parse_qs(urllib.parse.urlparse(href).query)
                if "uddg" in parsed:
                    href = urllib.parse.unquote(parsed["uddg"][0])
            self.current_result = {
                "url": href,
                "title": "",
                "snippet": ""
            }
        if tag == "a" and "result__snippet" in attrs_dict.get("class", ""):
            self.in_snippet = True
    
    def handle_endtag(self, tag):
        if tag == "a":
            if self.in_title:
                self.in_title = False
            if self.in_snippet:
                self.in_snippet = False
                if self.current_result.get("title"):
                    self.results.append(self.current_result.copy())
                    self.current_result = {}
                    self.in_result = False
    
    def handle_data(self, data):
        if self.in_title:
            self.current_result["title"] = (self.current_result.get("title", "") + data).strip()
        if self.in_snippet:
            self.current_result["snippet"] = (self.current_result.get("snippet", "") + data).strip()


def detect_search_needed(query: str) -> bool:
    """
    Detect if a query likely needs web search.
    
    Looks for indicators like:
    - Current events ("today", "recent", "latest")
    - Specific dates
    - News queries
    - Real-time information requests
    - "search", "find", "look up" keywords
    """
    query_lower = query.lower()
    
    # Time-sensitive keywords
    time_keywords = [
        "today", "yesterday", "recent", "latest", "current", "now",
        "this week", "this month", "2024", "2025",
        "what happened", "news", "breaking", "just", "happened"
    ]
    
    # Search action keywords
    search_keywords = [
        "search for", "look up", "find information", "check",
        "what is the current", "what are the latest", "what are the recent"
    ]
    
    # News-specific patterns (very lenient)
    news_patterns = [
        "what news", "recent news", "latest news", "current news",
        "what are the news", "tell me the news", "news",
        "what recent news", "what are recent news"
    ]
    
    # Allow almost any query with "news" to trigger search
    if "news" in query_lower:
        return True
    
    # Question patterns that suggest web search
    if any(keyword in query_lower for keyword in time_keywords):
        return True
    
    if any(keyword in query_lower for keyword in search_keywords):
        return True
    
    if any(pattern in query_lower for pattern in news_patterns):
        return True
    
    # Check for specific questions about current events
    question_patterns = [
        "who won", "who is", "what is happening",
        "what did", "when did", "where is"
    ]
    
    if any(pattern in query_lower for pattern in question_patterns):
        # Additional check: if it's a factual question, might need search
        if "?" in query:
            return True
    
    return False


def perform_search_and_format(query: str, max_results: int = 5) -> Optional[str]:
    """Perform web search and return formatted results."""
    service = get_web_search_service()
    results = service.search(query, max_results)
    
    if not results:
        return None
    
    return service.format_results_for_prompt(query, results)

