

from pydantic import BaseModel
from typing import Optional


class ReportByCourseId(BaseModel):
    course_id: str
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    file_path : Optional[str] = None