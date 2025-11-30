import re

BLOCK_TAG = r"#no_cloud"


def cloud_allowed(messages: list[dict]) -> bool:
    """Check if cloud routing is allowed based on message content."""
    text = "\n".join([m.get("content", "") for m in messages])
    return re.search(BLOCK_TAG, text) is None

