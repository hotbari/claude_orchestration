#!/usr/bin/env python3

"""
init-fastapi.py - Initialize FastAPI project with clean 3-layer architecture
Usage: python init-fastapi.py <project-name> [target-directory]
"""

import os
import sys
import argparse
import re
from pathlib import Path
from typing import Optional


class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color


def error_exit(message: str) -> None:
    """Print error message and exit"""
    print(f"{Colors.RED}Error: {message}{Colors.NC}", file=sys.stderr)
    sys.exit(1)


def success(message: str) -> None:
    """Print success message"""
    print(f"{Colors.GREEN}✓ {message}{Colors.NC}")


def info(message: str) -> None:
    """Print info message"""
    print(f"{Colors.YELLOW}→ {message}{Colors.NC}")


def validate_project_name(name: str) -> bool:
    """Validate project name (lowercase letters, numbers, underscores, hyphens)"""
    return bool(re.match(r'^[a-z0-9_-]+$', name))


def create_directory(path: Path) -> None:
    """Create directory if it doesn't exist"""
    path.mkdir(parents=True, exist_ok=True)


def write_file(path: Path, content: str) -> None:
    """Write content to file"""
    path.write_text(content, encoding='utf-8')


def init_fastapi_project(project_name: str, target_dir: Path) -> None:
    """Initialize FastAPI project structure"""

    project_path = target_dir / project_name

    # Check if project already exists
    if project_path.exists():
        error_exit(f"Project directory '{project_name}' already exists")

    info(f"Initializing FastAPI project: {project_name}")

    # Create project root
    create_directory(project_path)

    # Create main package directory
    package_name = project_name.replace('-', '_')
    src_path = project_path / package_name

    # Create directory structure
    directories = [
        src_path / 'api' / 'v1' / 'endpoints',
        src_path / 'api' / 'dependencies',
        src_path / 'services',
        src_path / 'repositories',
        src_path / 'models',
        src_path / 'schemas',
        src_path / 'core',
        project_path / 'tests' / 'api',
        project_path / 'tests' / 'services',
        project_path / 'alembic' / 'versions',
    ]

    for directory in directories:
        create_directory(directory)
        # Create __init__.py for Python packages
        if 'tests' in str(directory) or package_name in str(directory):
            write_file(directory / '__init__.py', '')

    success("Project structure created")

    # Create requirements.txt
    info("Creating requirements.txt...")
    requirements = """# Core
fastapi==0.109.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
pydantic-settings==2.1.0

# Database
sqlalchemy==2.0.25
alembic==1.13.1
psycopg2-binary==2.9.9

# Authentication
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6

# Utilities
python-dotenv==1.0.0
email-validator==2.1.0

# Development
pytest==7.4.4
pytest-asyncio==0.23.3
httpx==0.26.0
mypy==1.8.0
black==24.1.1
ruff==0.1.14
"""
    write_file(project_path / 'requirements.txt', requirements)
    success("requirements.txt created")

    # Create requirements-dev.txt
    requirements_dev = """# Include production requirements
-r requirements.txt

# Development tools
ipython==8.20.0
pytest-cov==4.1.0
pre-commit==3.6.0
"""
    write_file(project_path / 'requirements-dev.txt', requirements_dev)

    # Create core/config.py
    info("Creating configuration files...")
    config_content = f"""from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    \"\"\"Application settings\"\"\"

    # Application
    APP_NAME: str = "{project_name}"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # API
    API_V1_PREFIX: str = "/api/v1"

    # Database
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/{package_name}"

    # Security
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    BACKEND_CORS_ORIGINS: list[str] = ["http://localhost:3000"]

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
"""
    write_file(src_path / 'core' / 'config.py', config_content)

    # Create core/database.py
    database_content = """from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from .config import settings

engine = create_engine(settings.DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    \"\"\"Dependency to get database session\"\"\"
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
"""
    write_file(src_path / 'core' / 'database.py', database_content)

    # Create core/security.py
    security_content = """from datetime import datetime, timedelta
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext

from .config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    \"\"\"Verify a password against a hash\"\"\"
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    \"\"\"Hash a password\"\"\"
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    \"\"\"Create a JWT access token\"\"\"
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    \"\"\"Decode a JWT access token\"\"\"
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None
"""
    write_file(src_path / 'core' / 'security.py', security_content)
    success("Core configuration created")

    # Create main.py
    info("Creating main application file...")
    main_content = f"""from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from {package_name}.core.config import settings
from {package_name}.api.v1.api import api_router

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    openapi_url=f"{{settings.API_V1_PREFIX}}/openapi.json"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API router
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/")
async def root():
    \"\"\"Root endpoint\"\"\"
    return {{
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running"
    }}


@app.get("/health")
async def health_check():
    \"\"\"Health check endpoint\"\"\"
    return {{"status": "healthy"}}
"""
    write_file(src_path / 'main.py', main_content)

    # Create api router
    api_router_content = f"""from fastapi import APIRouter

from {package_name}.api.v1.endpoints import example

api_router = APIRouter()

# Include endpoint routers
api_router.include_router(example.router, prefix="/example", tags=["example"])
"""
    write_file(src_path / 'api' / 'v1' / 'api.py', api_router_content)

    # Create example endpoint
    example_endpoint_content = f"""from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from {package_name}.core.database import get_db
from {package_name}.schemas.example import ExampleCreate, ExampleResponse
from {package_name}.services.example_service import ExampleService

router = APIRouter()


@router.get("/", response_model=list[ExampleResponse])
async def get_examples(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    \"\"\"Get all examples\"\"\"
    service = ExampleService(db)
    examples = service.get_all(skip=skip, limit=limit)
    return examples


@router.post("/", response_model=ExampleResponse, status_code=201)
async def create_example(
    example: ExampleCreate,
    db: Session = Depends(get_db)
):
    \"\"\"Create a new example\"\"\"
    service = ExampleService(db)
    return service.create(example)


@router.get("/{{example_id}}", response_model=ExampleResponse)
async def get_example(
    example_id: int,
    db: Session = Depends(get_db)
):
    \"\"\"Get example by ID\"\"\"
    service = ExampleService(db)
    example = service.get_by_id(example_id)
    if not example:
        raise HTTPException(status_code=404, detail="Example not found")
    return example
"""
    write_file(src_path / 'api' / 'v1' / 'endpoints' / 'example.py', example_endpoint_content)

    # Create example schema
    schema_content = """from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional


class ExampleBase(BaseModel):
    \"\"\"Base example schema\"\"\"
    name: str
    description: Optional[str] = None


class ExampleCreate(ExampleBase):
    \"\"\"Schema for creating an example\"\"\"
    pass


class ExampleUpdate(ExampleBase):
    \"\"\"Schema for updating an example\"\"\"
    name: Optional[str] = None


class ExampleResponse(ExampleBase):
    \"\"\"Schema for example response\"\"\"
    id: int
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
"""
    write_file(src_path / 'schemas' / 'example.py', schema_content)

    # Create example model
    model_content = f"""from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func

from {package_name}.core.database import Base


class Example(Base):
    \"\"\"Example model\"\"\"
    __tablename__ = "examples"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
"""
    write_file(src_path / 'models' / 'example.py', model_content)

    # Create example repository
    repository_content = f"""from typing import Optional
from sqlalchemy.orm import Session

from {package_name}.models.example import Example
from {package_name}.schemas.example import ExampleCreate, ExampleUpdate


class ExampleRepository:
    \"\"\"Repository for Example model\"\"\"

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, example_id: int) -> Optional[Example]:
        \"\"\"Get example by ID\"\"\"
        return self.db.query(Example).filter(Example.id == example_id).first()

    def get_all(self, skip: int = 0, limit: int = 100) -> list[Example]:
        \"\"\"Get all examples\"\"\"
        return self.db.query(Example).offset(skip).limit(limit).all()

    def create(self, example_data: ExampleCreate) -> Example:
        \"\"\"Create a new example\"\"\"
        example = Example(**example_data.model_dump())
        self.db.add(example)
        self.db.commit()
        self.db.refresh(example)
        return example

    def update(self, example: Example, example_data: ExampleUpdate) -> Example:
        \"\"\"Update an example\"\"\"
        update_data = example_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(example, field, value)
        self.db.commit()
        self.db.refresh(example)
        return example

    def delete(self, example: Example) -> None:
        \"\"\"Delete an example\"\"\"
        self.db.delete(example)
        self.db.commit()
"""
    write_file(src_path / 'repositories' / 'example_repository.py', repository_content)

    # Create example service
    service_content = f"""from typing import Optional
from sqlalchemy.orm import Session

from {package_name}.repositories.example_repository import ExampleRepository
from {package_name}.schemas.example import ExampleCreate, ExampleUpdate
from {package_name}.models.example import Example


class ExampleService:
    \"\"\"Service for Example business logic\"\"\"

    def __init__(self, db: Session):
        self.repository = ExampleRepository(db)

    def get_by_id(self, example_id: int) -> Optional[Example]:
        \"\"\"Get example by ID\"\"\"
        return self.repository.get_by_id(example_id)

    def get_all(self, skip: int = 0, limit: int = 100) -> list[Example]:
        \"\"\"Get all examples\"\"\"
        return self.repository.get_all(skip=skip, limit=limit)

    def create(self, example_data: ExampleCreate) -> Example:
        \"\"\"Create a new example\"\"\"
        # Add business logic here (validation, transformation, etc.)
        return self.repository.create(example_data)

    def update(self, example_id: int, example_data: ExampleUpdate) -> Optional[Example]:
        \"\"\"Update an example\"\"\"
        example = self.repository.get_by_id(example_id)
        if not example:
            return None
        return self.repository.update(example, example_data)

    def delete(self, example_id: int) -> bool:
        \"\"\"Delete an example\"\"\"
        example = self.repository.get_by_id(example_id)
        if not example:
            return False
        self.repository.delete(example)
        return True
"""
    write_file(src_path / 'services' / 'example_service.py', service_content)
    success("Application code created")

    # Create .env.example
    info("Creating environment files...")
    env_content = f"""# Application
APP_NAME={project_name}
APP_VERSION=1.0.0
DEBUG=true

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/{package_name}

# Security
SECRET_KEY=your-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS
BACKEND_CORS_ORIGINS=["http://localhost:3000"]
"""
    write_file(project_path / '.env.example', env_content)

    # Create .gitignore
    gitignore_content = """# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Testing
.pytest_cache/
.coverage
htmlcov/

# Database
*.db
*.sqlite3

# Logs
*.log

# OS
.DS_Store
Thumbs.db
"""
    write_file(project_path / '.gitignore', gitignore_content)
    success("Configuration files created")

    # Create alembic.ini
    info("Creating Alembic configuration...")
    alembic_ini_content = f"""[alembic]
script_location = alembic
prepend_sys_path = .
sqlalchemy.url = postgresql://user:password@localhost:5432/{package_name}

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
"""
    write_file(project_path / 'alembic.ini', alembic_ini_content)

    # Create alembic env.py
    alembic_env_content = f"""from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context

from {package_name}.core.config import settings
from {package_name}.core.database import Base

# Import all models here for Alembic to detect
from {package_name}.models.example import Example

config = context.config
config.set_main_option('sqlalchemy.url', settings.DATABASE_URL)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={{"paramstyle": "named"}},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
"""
    write_file(project_path / 'alembic' / 'env.py', alembic_env_content)

    # Create alembic script.py.mako
    script_mako_content = '''"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
from alembic import op
import sqlalchemy as sa
${imports if imports else ""}

# revision identifiers, used by Alembic.
revision = ${repr(up_revision)}
down_revision = ${repr(down_revision)}
branch_labels = ${repr(branch_labels)}
depends_on = ${repr(depends_on)}


def upgrade() -> None:
    ${upgrades if upgrades else "pass"}


def downgrade() -> None:
    ${downgrades if downgrades else "pass"}
'''
    write_file(project_path / 'alembic' / 'script.py.mako', script_mako_content)
    success("Alembic configuration created")

    # Create README.md
    info("Creating README...")
    readme_content = f"""# {project_name}

FastAPI project with clean 3-layer architecture.

## Project Structure

```
{package_name}/
├── api/                  # API layer
│   ├── v1/
│   │   ├── endpoints/   # API endpoints
│   │   └── dependencies/ # Route dependencies
├── services/            # Business logic layer
├── repositories/        # Data access layer
├── models/             # SQLAlchemy models
├── schemas/            # Pydantic schemas
└── core/               # Core functionality
    ├── config.py       # Configuration
    ├── database.py     # Database setup
    └── security.py     # Security utilities
```

## Getting Started

1. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\\Scripts\\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Copy `.env.example` to `.env` and configure:
   ```bash
   cp .env.example .env
   ```

4. Initialize the database:
   ```bash
   alembic upgrade head
   ```

5. Run the development server:
   ```bash
   uvicorn {package_name}.main:app --reload
   ```

6. Open [http://localhost:8000/docs](http://localhost:8000/docs) for API documentation.

## Development

### Create a new migration:
```bash
alembic revision --autogenerate -m "description"
```

### Apply migrations:
```bash
alembic upgrade head
```

### Run tests:
```bash
pytest
```

### Type checking:
```bash
mypy {package_name}
```

### Code formatting:
```bash
black {package_name}
```

### Linting:
```bash
ruff {package_name}
```

## Architecture

This project follows a clean 3-layer architecture:

1. **API Layer** (`api/`): FastAPI endpoints, request/response handling
2. **Service Layer** (`services/`): Business logic, validation, orchestration
3. **Repository Layer** (`repositories/`): Database operations, queries

This separation provides:
- Clear separation of concerns
- Testability
- Maintainability
- Flexibility to change implementation details

## Dependencies

- **FastAPI**: Modern, fast web framework
- **SQLAlchemy**: SQL toolkit and ORM
- **Alembic**: Database migration tool
- **Pydantic**: Data validation using Python type hints
- **Uvicorn**: ASGI server

Created with init-fastapi.py
"""
    write_file(project_path / 'README.md', readme_content)
    success("README created")

    # Create pytest configuration
    pytest_ini_content = """[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --strict-markers
"""
    write_file(project_path / 'pytest.ini', pytest_ini_content)

    # Create example test
    test_content = f"""import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from {package_name}.main import app
from {package_name}.core.database import Base, get_db

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={{"check_same_thread": False}})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_database():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "name" in response.json()


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {{"status": "healthy"}}
"""
    write_file(project_path / 'tests' / 'test_main.py', test_content)
    success("Tests created")

    # Create mypy configuration
    mypy_content = f"""[mypy]
python_version = 3.11
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True

[mypy-{package_name}.migrations.*]
ignore_errors = True
"""
    write_file(project_path / 'mypy.ini', mypy_content)

    # Print summary
    print()
    print(f"{Colors.GREEN}{'=' * 64}{Colors.NC}")
    print(f"{Colors.GREEN}  FastAPI project initialized successfully!{Colors.NC}")
    print(f"{Colors.GREEN}{'=' * 64}{Colors.NC}")
    print()
    print(f"Project: {Colors.YELLOW}{project_name}{Colors.NC}")
    print(f"Location: {Colors.YELLOW}{project_path.absolute()}{Colors.NC}")
    print()
    print("Next steps:")
    print(f"  1. cd {project_name}")
    print("  2. python -m venv venv")
    print("  3. source venv/bin/activate  # On Windows: venv\\Scripts\\activate")
    print("  4. pip install -r requirements.txt")
    print("  5. cp .env.example .env")
    print(f"  6. uvicorn {package_name}.main:app --reload")
    print()


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Initialize FastAPI project with clean 3-layer architecture'
    )
    parser.add_argument('project_name', help='Name of the project')
    parser.add_argument(
        'target_dir',
        nargs='?',
        default='.',
        help='Target directory (default: current directory)'
    )

    args = parser.parse_args()

    # Validate project name
    if not validate_project_name(args.project_name):
        error_exit(
            "Project name must contain only lowercase letters, numbers, underscores, and hyphens"
        )

    # Get target directory
    target_dir = Path(args.target_dir).resolve()

    # Create target directory if needed
    if not target_dir.exists():
        info(f"Creating target directory: {target_dir}")
        target_dir.mkdir(parents=True)

    # Initialize project
    try:
        init_fastapi_project(args.project_name, target_dir)
    except Exception as e:
        error_exit(str(e))


if __name__ == '__main__':
    main()
