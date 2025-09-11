
# SQLAlchemy model for faculty table
from sqlalchemy import Column, String
from app.db.base import Base

class Faculty(Base):
    __tablename__ = "faculty"
    fact_id = Column(String(255), primary_key=True)
    fact_name = Column(String(255), nullable=False)
