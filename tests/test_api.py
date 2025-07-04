import logging

import pytest
from fastapi import testclient
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import Address, User
from src.db.session import get_async_session
from src.main import app

logger = logging.getLogger(__name__)
client = testclient.TestClient(app)


@pytest.fixture()
async def test_session(db_session: AsyncSession) -> AsyncSession:
    """Create multiple test users with addresses and return them."""
    test_data = [
        {"name": "test1", "fullname": "Test User 1", "email": "test1@example.com"},
        {"name": "test2", "fullname": "Test User 2", "email": "test2@example.com"},
    ]

    users = []
    for data in test_data:
        user = User(
            name=data["name"],
            fullname=data["fullname"],
        )
        user.addresses.append(Address(email_address=data["email"]))
        users.append(user)

    db_session.add_all(users)
    await db_session.commit()

    return db_session


@pytest.mark.asyncio
async def test_get_users(test_session: AsyncSession):
    async with test_session as session:
        app.dependency_overrides[get_async_session] = lambda: session
        response = client.get("/users?num_results=2")
        assert response.status_code == 200
        assert len(response.json()) == 2


@pytest.mark.asyncio
async def test_create_and_get_user(test_session: AsyncSession):
    user_data = {
        "name": "newuser",
        "fullname": "New User",
        "email_address": "new@example.com",
    }
    async with test_session as session:
        app.dependency_overrides[get_async_session] = lambda: session
        response = client.post("/users", json=user_data)
        assert response.status_code == 200
        post_data = response.json()
        assert post_data["name"] == user_data["name"]
        assert post_data["addresses"][0]["email_address"] == user_data["email_address"]

        response = client.get(f"/users/{post_data['id']}")
        assert response.status_code == 200
        get_data = response.json()
        assert get_data["name"] == user_data["name"]
        assert get_data["addresses"][0]["email_address"] == user_data["email_address"]
