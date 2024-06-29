from typing import List
from datetime import date, datetime

from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from sapi import crud, models, schemas
from sapi.database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# Health check endpoint
@app.get("/health", status_code=200)
def health_check():
    return {"status": "ok"}


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.put("/hello/{user_name}", status_code=204)
def update_user(user_name: str, user_update: schemas.UserUpdate, db: Session = Depends(get_db)):
    if not user_name.isalpha():
        raise HTTPException(status_code=400, detail="Username must contain only letters")
    if user_update.birthday >= date.today():
        raise HTTPException(status_code=400, detail="Birthday must be a date before today")
    db_user = crud.get_user(db, user_name=user_name)
    if db_user is None:
        db_user = crud.create_user(db, schemas.UserCreate(name=user_name, birthday=user_update.birthday))
    else:
        db_user = crud.update_user(db, db_user, user_update.birthday)
    return

@app.get("/hello/{user_name}", response_model=schemas.Message)
def read_user(user_name: str, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_name=user_name)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    today = date.today()
    birthday_this_year = db_user.birthday.replace(year=today.year)
    if birthday_this_year < today:
        birthday_this_year = birthday_this_year.replace(year=today.year + 1)
    
    days_until_birthday = (birthday_this_year - today).days

    if days_until_birthday == 0:
        message = f"Hello, {user_name}! Happy birthday!"
    else:
        message = f"Hello, {user_name}! Your birthday is in {days_until_birthday} day(s)"

    return schemas.Message(message=message)
