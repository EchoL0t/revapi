from datetime import date
from typing import List, Union
from pydantic import BaseModel

class UserBase(BaseModel):
    name: str
    birthday: date

class UserCreate(UserBase):
    pass

class UserUpdate(BaseModel):
    birthday: date

class User(UserBase):
    id: int
    name: str
    birthday: date

    class Config:
        orm_mode = True

class Message(BaseModel):
    message: str
