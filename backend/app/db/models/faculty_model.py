
# SQLAlchemy model for faculty table
from sqlalchemy import Column, String
from app.db.base import Base

class Faculty(Base):
    __tablename__ = "faculty"
    factid = Column(String(255), primary_key=True)
    name = Column(String(255), nullable=False)
