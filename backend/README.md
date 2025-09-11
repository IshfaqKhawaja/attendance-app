## Attendance App Backend - Project Structure & Documentation

### Quick Start

**Start PostgreSQL (Docker):**
```sh
docker run --name local-postgres -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword -e POSTGRES_DB=mydb \
  -p 5432:5432 -d postgres:latest
```

**Drop Database:**
```sh
docker exec local-postgres \
  psql -U myuser -d postgres \
  -c "SELECT pg_terminate_backend(pid) \
      FROM pg_stat_activity \
     WHERE datname='mydb' AND pid<>pg_backend_pid(); \
    DROP DATABASE IF EXISTS mydb;"
```

**Run Project:**
```sh
uv run uvicorn app.main:app --reload
```

---

## Project Structure

```
backend/
│
├── app/
│   ├── main.py                # FastAPI app entrypoint
│   ├── api/
│   │   ├── v1/                # Versioned API routers (attendance, auth, etc.)
│   ├── core/                  # Core logic (config, mail, scheduler, security)
│   ├── db/
│   │   ├── base.py            # SQLAlchemy Base
│   │   ├── connection.py      # DB connection setup
│   │   ├── crud/              # CRUD operations for each entity
│   │   ├── models/            # SQLAlchemy ORM models (one file per table)
│   │   ├── migrations/        # Alembic migrations
│   │   ├── session.py         # Session management
│   ├── schemas/               # Pydantic schemas for request/response validation
│   ├── services/              # Business logic/services (report generation, etc.)
│   ├── utils/                 # Utility functions (excel/pdf generation, etc.)
│   └── dependencies.py        # FastAPI dependencies
│
├── tests/                     # Unit and integration tests
├── scripts/                   # Standalone scripts (e.g., create_all_tables.py)
├── json_data/                 # Static data files (departments, programs, etc.)
├── Dockerfile                 # Containerization
├── pyproject.toml             # Project metadata & dependencies
├── README.md                  # Project documentation
└── requirements.txt           # (if not using poetry/pyproject.toml)
```

---

## Folder & File Documentation

### app/main.py
Entry point for FastAPI application. Includes all routers and middleware setup.

### app/api/v1/
Contains all API routers, each file handles endpoints for a specific entity (faculty, department, program, etc.).

### app/core/
Holds core logic such as configuration, mail sending, scheduler, secrets, and security utilities.

### app/db/
- **base.py**: Declares SQLAlchemy Base for ORM models.
- **connection.py**: Handles database connection logic.
- **crud/**: Contains CRUD operations for each table/entity.
- **models/**: Contains SQLAlchemy ORM models (one file per table).
- **migrations/**: Alembic migration scripts for DB schema changes.
- **session.py**: Manages DB sessions.

### app/schemas/
Contains Pydantic models for request/response validation for each table/entity.

### app/services/
Business logic and services, e.g., report generation, attendance notification.

### app/utils/
Utility functions for tasks like Excel/PDF generation, OTP verification, etc.

### tests/
Unit and integration tests for all modules and endpoints.

### scripts/
Standalone scripts for DB setup, migrations, etc.

### json_data/
Static data files (departments, programs, faculty, etc.) used for seeding or reference.

### Dockerfile
Defines containerization for the backend app.

### pyproject.toml / requirements.txt
Project dependencies and metadata.

---

## Code Documentation

- **Routers**: Each router in `app/api/v1/` exposes REST endpoints for CRUD and business logic for a specific entity.
- **CRUD**: Each file in `app/db/crud/` implements database operations for its entity, using SQLAlchemy models and Pydantic schemas.
- **Models**: Each file in `app/db/models/` defines a SQLAlchemy ORM class mapping to a DB table.
- **Schemas**: Each file in `app/schemas/` defines Pydantic models for request/response validation.
- **Services**: Encapsulate business logic, e.g., generating reports, sending notifications.
- **Utils**: Helper functions for common tasks (file generation, ID creation, etc.).

---

## Getting Started

1. **Install dependencies:**
  ```sh
  pip install -r requirements.txt
  ```
2. **Start PostgreSQL (see above).**
3. **Run DB setup scripts (if needed):**
  ```sh
  python scripts/create_all_tables.py
  ```
4. **Run the backend server:**
  ```sh
  uv run uvicorn app.main:app --reload
  ```
5. **Run tests:**
  ```sh
  pytest
  ```

---

## Contributing

Please follow the structure and naming conventions described above. Add documentation for any new modules or features in this README.



## ER Diagram of Whole Project
erDiagram
    FACULTY ||--o{ DEPARTMENT : "has"
    DEPARTMENT ||--o{ PROGRAM : "offers"
    DEPARTMENT ||--o{ TEACHER : "employs"
    DEPARTMENT ||--o{ STUDENT : "admits"
    DEPARTMENT ||--o{ USERS : "manages"
    PROGRAM ||--o{ SEMESTER : "contains"
    SEMESTER ||--o{ COURSE : "offers"

    STUDENT ||--o{ STUDENT_ENROLLMENT : "enrolls in"
    SEMESTER ||--o{ STUDENT_ENROLLMENT : "is enrolled in"

    TEACHER ||--o{ TEACHER_COURSE : "teaches"
    COURSE ||--o{ TEACHER_COURSE : "is taught by"

    STUDENT ||--o{ COURSE_STUDENT : "takes"
    COURSE ||--o{ COURSE_STUDENT : "is taken by"

    STUDENT ||--o{ ATTENDANCE : "record for"
    COURSE ||--o{ ATTENDANCE : "record in"