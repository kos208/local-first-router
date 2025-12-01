"""
Claude tool definitions for function calling.
"""

from typing import List, Dict


def get_web_search_tool() -> Dict:
    """Get web search tool definition for Claude."""
    return {
        "name": "web_search",
        "description": "Search the web for current information, news, or real-time data. Use this when the user asks about current events, recent news, real-time data, or information that may have changed recently.",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "The search query to look up on the web"
                }
            },
            "required": ["query"]
        }
    }


def build_tools_list(enable_web_search: bool = True) -> List[Dict]:
    """Build list of available tools for Claude."""
    tools = []
    if enable_web_search:
        tools.append(get_web_search_tool())
    return tools


def handle_tool_use(tool_name: str, tool_input: Dict) -> Dict:
    """
    Handle tool/function calls from Claude.
    
    Returns tool result that will be passed back to Claude.
    """
    if tool_name == "web_search":
        from .web_search import get_web_search_service
        query = tool_input.get("query", "")
        service = get_web_search_service()
        results = service.search(query, max_results=5)
        
        if not results:
            return {
                "type": "text",
                "text": f"No search results found for: {query}"
            }
        
        # Format results
        formatted = service.format_results_for_prompt(query, results)
        return {
            "type": "text",
            "text": formatted
        }
    
    return {
        "type": "text",
        "text": f"Unknown tool: {tool_name}"
    }

