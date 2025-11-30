from sqlalchemy import Column, Integer, String, Float, Text, DateTime
from sqlalchemy.sql import func
from .db import Base


class LogEntry(Base):
    __tablename__ = "logs"
    
    id = Column(Integer, primary_key=True)
    route = Column(String)  # local or cloud
    prompt_hash = Column(String, index=True)
    confidence = Column(Float)
    latency_ms = Column(Integer)
    estimated_cost_usd = Column(Float)
    estimated_cost_saved_usd = Column(Float)
    request = Column(Text)
    response = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

