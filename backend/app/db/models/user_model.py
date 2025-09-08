from typing import Optional
from pydantic import BaseModel, Field # type: ignore

class AddUser(BaseModel):
    user_id: str = Field(..., description="ID of the User")
    user_name: str = Field(..., description="Name of the new User")
    type: str = Field(..., description="Type of User (GUEST, PERMANENT, CONTRACT)")
    dept_id: Optional[str] = Field(..., description="Dept id to which User belongs")
    fact_id: Optional[str] = Field(..., description="Faculty ID to which User belongs")


# Request model for displaying a user
class DisplayUser(BaseModel):
    user_id: str = Field(..., description="User ID")
