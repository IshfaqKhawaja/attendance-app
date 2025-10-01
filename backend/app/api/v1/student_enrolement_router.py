import io
# from turtle import st  # Removed - this was causing import errors
from fastapi import APIRouter, HTTPException
from sqlalchemy import intersect

from app.db.crud.student import add_students_in_bulk
from app.db.crud.student_enrolement import add_student_enrolled_in_sem, add_students_enrolled_in_sem_bulk, display_students_by_sem_id, fetch_students_by_course_id
from app.db.models.student_enrolement_model import BulkStudentEnrolementModel, DisplayStudentsBySemIdResponseModel, StudentEnrolementModel, StudentEnrollmentDetailsModel
from fastapi import File, UploadFile
from fastapi import Form
import pandas as pd

from app.db.models.student_model import BulkStudentIn





router = APIRouter(
     prefix="/student_enrollment",
     tags=["student_enrolement"]
)

@router.post("/add", response_model=dict, summary="Enroll a student in a semester")
def add_student_enrolement(student: StudentEnrolementModel):
    """Add a student enrollment record."""
    return add_student_enrolled_in_sem(student)


@router.post("/add_bulk", response_model=dict, summary="Enroll multiple students in semesters")
def add_students_enrolement(students: BulkStudentEnrolementModel):
    """Add multiple student enrollment records."""
    return add_students_enrolled_in_sem_bulk(students)


@router.post("/upload_bulk_enrollment_file", response_model=dict, summary="Upload a file to enroll multiple students in semesters")
async def upload_bulk_enrolement_file(
    sem_id: str = Form(...),
    file: UploadFile = File(...)
):
    """Upload a file to add multiple student enrollment records."""
    
    contents = await file.read()
    
    try:
        # Use io.BytesIO to treat the bytes as a file
        buffer = io.BytesIO(contents)
        
        # --- LOGIC TO READ THE FILE ---
        
        # Check the filename to decide how to read it
        if file.filename.endswith('.csv'): # type: ignore
            df = pd.read_csv(buffer)
        elif file.filename.endswith(('.xlsx', '.xls')): # type: ignore
            # For Excel, you might need to install `openpyxl`
            df = pd.read_excel(buffer)
        else:
            raise HTTPException(status_code=400, detail="Invalid file type. Please upload a CSV or Excel file.")

        # Now you can work with the DataFrame
        print("File read successfully. DataFrame head:")
        columns = ["student_id", "student_name", "phone_number"]
        students = []
        # if set(columns).intersection(set(df.columns)) != set(columns):
        #     print(set(df.columns))
        #     return {
        #         "success": False,
        #         "message": f"File must contain the following columns: {columns}"
        #     }
        #  Add Students to DB
        # for _, row in df.iterrows():
        #     student = {
        #         "student_id": str(row["student_id"]),
        #         "student_name": row["student_name"],
        #         "phone_number": str(row["phone_number"]),
        #         "sem_id": sem_id
        #     }
        #     students.append(student)
        # print(students)
        print(df.head())
        
        # For now just read the columns
        students = []
        for _, row in df.iterrows():
            student_id = row.iloc[0]
            student_name = row.iloc[1]
            phone_number = row.iloc[2]
            if type(student_id) != str:
                student_id = str(student_id)
            if type(phone_number) != str:
                phone_number = str(phone_number)
             # Create student dict
            student = {
                "student_id": student_id,
                "student_name": student_name,
                "phone_number": phone_number,
                "sem_id": sem_id
            }
            students.append(student)
        # Add Bulk Students to DB
        bulk_students = BulkStudentIn(students=students)
        details = add_students_in_bulk(bulk_students)
        print(f"Students added: {details}")
        if not details["success"]:
            return {
                "success": False,
                "message": "Failed to add students to DB."
            }
        
        # Add Bulk Student Enrollment to DB
        details =  add_students_enrolled_in_sem_bulk(
            BulkStudentEnrolementModel(enrolements=[
                StudentEnrolementModel(
                    student_id=st["student_id"],
                    sem_id=sem_id
                ) for st in students
            ])
        )
        print(f"Enrollments added: {details}")
        return details
        
    except Exception as e:
        return {
            "success": False,
            "message": f"Error processing file: {str(e)}"
        }
    
    finally:
        buffer.close() # type: ignore
        
        
@router.get("/display_by_sem_id/{sem_id}", response_model=DisplayStudentsBySemIdResponseModel, summary="Get students enrolled in a semester")
async def display_by_sem_id(sem_id: str)-> DisplayStudentsBySemIdResponseModel:
    """Get students enrolled in a particular semester."""
    return display_students_by_sem_id(sem_id)




@router.get("/fetch_students/{course_id}", response_model=StudentEnrollmentDetailsModel, summary="Fetch Students by Course ID")
def fetch_students(course_id: str) -> StudentEnrollmentDetailsModel:
    return fetch_students_by_course_id(course_id=course_id)