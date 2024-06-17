from sqlalchemy.orm import Session
from datetime import date

from sapi import models, schemas

def get_user(db: Session, user_name: str):
    return db.query(models.User).filter(models.User.name == user_name).first()

def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(name=user.name, birthday=user.birthday)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user(db: Session, db_user: models.User, birthday: date):
    db_user.birthday = birthday
    db.commit()
    db.refresh(db_user)
    return db_user
