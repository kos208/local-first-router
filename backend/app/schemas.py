from pydantic import BaseModel
from typing import List, Optional, Literal, Any


class Message(BaseModel):
    role: Literal["system", "user", "assistant", "tool"] = "user"
    content: str
    image: Optional[str] = None  # Base64-encoded image or image URL


class ChatRequest(BaseModel):
    model: Optional[str] = None
    messages: List[Message]
    temperature: Optional[float] = 0.2
    stream: Optional[bool] = False
    conversation_id: Optional[str] = None
    image: Optional[str] = None  # Base64-encoded image for the last message


class ChoiceMsg(BaseModel):
    role: str = "assistant"
    content: str


class Choice(BaseModel):
    index: int
    message: ChoiceMsg


class ChatResponse(BaseModel):
    id: str
    object: str = "chat.completion"
    choices: list[Choice]
    usage: dict[str, Any] = {}
    model: str
    local_model: Optional[str] = None
    route: str  # "local" or "cloud"
    confidence: float
    latency_ms: int
    estimated_cost_usd: float
    estimated_cost_saved_usd: float
    conversation_id: Optional[str] = None

