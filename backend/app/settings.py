from pydantic_settings import BaseSettings
from typing import Optional, List


class Settings(BaseSettings):
    OLLAMA_BASE: str = "http://localhost:11434"
    LOCAL_MODELS: List[str] = ["llama3.2:latest", "llama3.1:8b-instruct-q4_K_M"]
    LOCAL_MODEL: str = "llama3.2:latest"
    LOCAL_TEMPERATURE: float = 0.7
    LOCAL_MAX_TOKENS: Optional[int] = None
    ANTHROPIC_BASE: str = "https://api.anthropic.com"
    ANTHROPIC_API_KEY: Optional[str] = None
    ANTHROPIC_BETA: Optional[str] = None
    CLOUD_MODEL: str = "claude-3-haiku-20240307"
    CLOUD_MAX_TOKENS: Optional[int] = 1024
    CONFIDENCE_THRESHOLD: float = 0.7
    DB_URL: str = "sqlite:///./router.db"
    CACHE_TTL_SECONDS: int = 300
    MAX_LOG_ROWS: int = 5000
    PRICE_PER_1K_INPUT: float = 0.005   # default estimate for cloud model
    PRICE_PER_1K_OUTPUT: float = 0.015

    class Config:
        env_file = ".env"


settings = Settings()

