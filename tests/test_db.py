import pytest
from sqlalchemy.exc import IntegrityError

from src.db.models import Address, User


@pytest.mark.parametrize("name, fullname", [("test", "Test User"), ("test2", None)])
@pytest.mark.asyncio
async def test_create_user(db_session, name, fullname):
    user = User(name=name, fullname=fullname)
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)
    assert user.name == name
    assert user.fullname == fullname


@pytest.mark.asyncio
async def test_create_address(db_session):
    user = User(name="test", fullname="Test User")
    address = Address(email_address="test@example.com")
    user.addresses.append(address)
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(address)
    await db_session.refresh(user)
    assert address.id is not None
    assert address.email_address == "test@example.com"
    assert address.user_id == user.id


@pytest.mark.asyncio
async def test_create_address_fails(db_session):
    user = User(name="test", fullname="Test User")
    address = Address(email_address=None)
    user.addresses.append(address)
    db_session.add(user)

    with pytest.raises(IntegrityError):
        await db_session.commit()
