import unittest
from datetime import date
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sapi import models, crud, schemas
from sapi.database import Base

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)

class TestCRUD(unittest.TestCase):

    def setUp(self):
        self.db = TestingSessionLocal()

    def tearDown(self):
        self.db.query(models.User).delete()
        self.db.commit()
        self.db.close()

    def test_create_user(self):
        user_create = schemas.UserCreate(name="JohnDoe", birthday=date(1990, 1, 1))
        user = crud.create_user(self.db, user=user_create)
        self.assertEqual(user.name, "JohnDoe")
        self.assertEqual(user.birthday, date(1990, 1, 1))

    def test_get_user(self):
        user_create = schemas.UserCreate(name="JohnDoe", birthday=date(1990, 1, 1))
        crud.create_user(self.db, user=user_create)
        user = crud.get_user(self.db, user_name="JohnDoe")
        self.assertIsNotNone(user)
        self.assertEqual(user.name, "JohnDoe")

    def test_update_user(self):
        user_create = schemas.UserCreate(name="JohnDoe", birthday=date(1990, 1, 1))
        user = crud.create_user(self.db, user=user_create)
        updated_user = crud.update_user(self.db, db_user=user, birthday=date(1991, 1, 1))
        self.assertEqual(updated_user.birthday, date(1991, 1, 1))

if __name__ == '__main__':
    unittest.main()
