from sqlalchemy import Column, String, Date, Boolean, ForeignKey
from app.db.base import Base

class Attendance(Base):
    __tablename__ = "attendance"
    student_id = Column(String(255), ForeignKey("students.student_id", ondelete="CASCADE"), primary_key=True)
    course_id = Column(String(255), ForeignKey("course.course_id", ondelete="CASCADE"), primary_key=True)
    date = Column(Date, primary_key=True)
    present = Column(Boolean, nullable=False, default=False)