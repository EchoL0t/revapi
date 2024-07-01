from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import pytest
from datetime import date, timedelta
import os

from sapi.database import Base, get_db
from sapi.main import app
from sapi import models, crud, schemas

# Set the database URL to use an in-memory SQLite database
os.environ["DATABASE_URL"] = "sqlite:///./test.db"

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

@pytest.fixture(autouse=True)
def setup_and_teardown():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

def calculate_days_until_birthday(birthday: date):
    today = date.today()
    next_birthday = birthday.replace(year=today.year)
    if next_birthday < today:
        next_birthday = next_birthday.replace(year=today.year + 1)
    return (next_birthday - today).days

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_update_user_create_new():
    user_update = {"birthday": "1990-01-01"}
    response = client.put("/hello/JohnDoe", json=user_update)
    assert response.status_code == 204

    response = client.get("/hello/JohnDoe")
    assert response.status_code == 200

    days_until_birthday = calculate_days_until_birthday(date(1990, 1, 1))
    assert response.json() == {
        "message": f"Hello, JohnDoe! Your birthday is in {days_until_birthday} day(s)"
    }

def test_update_user_existing():
    user_create = schemas.UserCreate(name="JohnDoe", birthday=date(1990, 1, 1))
    db = next(override_get_db())
    crud.create_user(db, user=user_create)

    user_update = {"birthday": "1991-01-01"}
    response = client.put("/hello/JohnDoe", json=user_update)
    assert response.status_code == 204

    response = client.get("/hello/JohnDoe")
    assert response.status_code == 200

    days_until_birthday = calculate_days_until_birthday(date(1991, 1, 1))
    assert response.json() == {
        "message": f"Hello, JohnDoe! Your birthday is in {days_until_birthday} day(s)"
    }

def test_read_user_not_found():
    response = client.get("/hello/UnknownUser")
    assert response.status_code == 404
    assert response.json() == {"detail": "User not found"}
