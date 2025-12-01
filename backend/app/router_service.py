import json
import re
import time
from .settings import settings
from .clients import ollama_client, claude_client
from .policy import cloud_allowed
from .cache import key_for_messages, cache_get, cache_set
from .services.web_search import detect_search_needed, perform_search_and_format

CONF_SYS = {
    "role": "system",
    "content": (
        "You are an expert assistant.\n"
        "\n"
        "OUTPUT FORMAT (MANDATORY):\n"
        "Respond ONLY with a JSON object in this exact schema:\n"
        "{\n"
        "  \"answer\": \"...\",\n"
        "  \"confidence\": <number between 0 and 1>\n"
        "}\n"
        "\n"
        "RULES FOR JSON OUTPUT:\n"
        "- Never include explanations outside the JSON.\n"
        "- Always fill both fields.\n"
        "\n"
        "WEB SEARCH RESULTS:\n"
        "- If web search results are provided in the conversation context, use them to answer with current, up-to-date information.\n"
        "- Base your answer on the search results when they are available.\n"
        "- Do not request additional searches; use the provided information.\n"
        "\n"
        "CONTENT REQUIREMENTS:\n"
        "- Provide a thorough, multi-paragraph answer inside \"answer\".\n"
        "- Include step-by-step reasoning, structured explanations, examples, and caveats when helpful.\n"
        "- Leverage earlier conversation context when relevant.\n"
        "- Do not mention the JSON format inside the answer.\n"
        "\n"
        "MATH FORMATTING:\n"
        "- Inline math: $expression$\n"
        "- Display math: $$expression$$\n"
        "\n"
        "CONFIDENCE FIELD:\n"
        "- \"confidence\" = your estimated probability that a domain expert would judge your answer correct.\n"
        "- Use lower confidence when guessing, dealing with sparse data, or answering ambiguous questions.\n"
        "- Higher confidence when using provided search results or established facts.\n"
        "\n"
        "EXAMPLE:\n"
        "{\n"
        "  \"answer\": \"The quadratic formula is $x = \\\\frac{-b \\\\pm \\\\sqrt{b^2 - 4ac}}{2a}$. This is a fundamental result in algebra...\",\n"
        "  \"confidence\": 0.9\n"
        "}\n"
    )
}


def parse_json_block(text: str):
    """Extract JSON from model response, handling various formats."""
    m = re.search(r"\{.*\}", text, re.S)
    if not m:
        return {"answer": text.strip(), "confidence": 0.0}
    block = m.group(0)
    try:
        obj = json.loads(block)
        return {
            "answer": obj.get("answer", "").strip(),
            "confidence": float(obj.get("confidence", 0))
        }
    except Exception:
        # Attempt a lenient parse when JSON is slightly malformed (e.g. single backslashes)
        answer = ""
        confidence = 0.0
        
        ans_match = re.search(r'"answer"\s*:\s*"(.*?)"\s*(,|})', block, re.S)
        if ans_match:
            raw_answer = ans_match.group(1)
            try:
                answer = bytes(raw_answer, "utf-8").decode("unicode_escape")
            except Exception:
                answer = raw_answer
            answer = answer.replace("\\\"", "\"").strip()
        
        conf_match = re.search(r'"confidence"\s*:\s*([0-9]+\.?[0-9]*)', block)
        if conf_match:
            try:
                confidence = float(conf_match.group(1))
            except ValueError:
                confidence = 0.0
        
        if not answer:
            answer = text.strip()
        
        return {
            "answer": answer,
            "confidence": confidence
        }


def try_local(messages, temperature=None, model=None):
    """Try local model with confidence-aware system prompt and deterministic web search."""
    start = time.time()
    temp = temperature if temperature is not None else settings.LOCAL_TEMPERATURE
    max_tokens = settings.LOCAL_MAX_TOKENS
    web_search_used = False
    
    # Always perform web search before calling model
    enhanced_messages = messages.copy()
    
    if settings.ENABLE_WEB_SEARCH and messages:
        last_message = messages[-1]
        if last_message.get("role") == "user":
            user_query = last_message.get("content", "")
            # Always perform web search for every query
            print(f"Performing web search for query: {user_query[:100]}...")
            search_query = user_query
            # Perform search automatically
            search_results = perform_search_and_format(search_query, settings.WEB_SEARCH_MAX_RESULTS)
            if search_results:
                # Inject search results as system message before user query
                enhanced_messages = messages[:-1] + [
                    {
                        "role": "system",
                        "content": f"Web search was performed to get current and relevant information. Here are the search results:\n\n{search_results}\n\nUse this information to provide an accurate, up-to-date answer to the user's question. If the search results don't contain relevant information for the question, you can still answer based on your knowledge."
                    },
                    messages[-1]  # Original user message
                    ]
                web_search_used = True
                print(f"Web search results injected into prompt ({len(search_results)} characters)")
            else:
                print("Web search returned no results, proceeding without search results")
    
    try:
        # Combine system prompt with enhanced messages (search results already included if needed)
        final_messages = [CONF_SYS] + enhanced_messages
        res = ollama_client.chat(
            messages=final_messages,
            temperature=temp,
            max_tokens=max_tokens,
            model=model or settings.LOCAL_MODEL
        )
        
        txt = res["choices"][0]["message"]["content"]
        print(f"Local model response: {txt[:200]}...")  # Debug log
        parsed = parse_json_block(txt)
        latency = int((time.time() - start) * 1000)
        usage = res.get("usage", {})
        if web_search_used:
            usage["web_search_used"] = True
        print(f"Parsed: answer length={len(parsed.get('answer', ''))}, confidence={parsed.get('confidence')}, search_used={web_search_used}")
        return parsed, latency, usage
    except Exception as e:
        print(f"Error in try_local: {str(e)}")
        raise


def call_cloud(messages, temperature=None):
    """Call cloud model with optional web search support."""
    start = time.time()
    temp = temperature if temperature is not None else 0.2
    
    # Check if web search might be needed and enhance prompt
    enhanced_messages = messages.copy()
    web_search_used = False
    
    if settings.ENABLE_WEB_SEARCH and messages:
        last_message = messages[-1]
        if last_message.get("role") == "user":
            query = last_message.get("content", "")
            # Always perform web search for Claude as well
            print(f"Performing web search for Claude query: {query[:100]}...")
            search_results = perform_search_and_format(query, settings.WEB_SEARCH_MAX_RESULTS)
            if search_results:
                # Add search results as context before user message
                enhanced_messages = messages[:-1] + [
                    {
                        "role": "system",
                        "content": f"Web search was performed to get current and relevant information. Here are the search results:\n\n{search_results}\n\nUse this information to provide an accurate, up-to-date answer. If the search results don't contain relevant information, you can still answer based on your knowledge."
                    },
                    messages[-1]
                ]
                web_search_used = True
                print(f"Web search results added to Claude prompt")
            else:
                print("Web search returned no results for Claude, proceeding without search results")
    
    res = claude_client.chat(
        messages=enhanced_messages,
        temperature=temp,
        max_tokens=settings.CLOUD_MAX_TOKENS,
    )
    txt = res["choices"][0]["message"]["content"]
    latency = int((time.time() - start) * 1000)
    usage = res.get("usage", {})
    if web_search_used:
        usage["web_search_used"] = True
    return txt, latency, usage

