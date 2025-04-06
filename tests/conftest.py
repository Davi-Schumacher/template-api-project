import os

import pytest
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

from src.db.models import Base

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set")

# Create test engine
test_engine = create_async_engine(DATABASE_URL, echo=False)


@pytest.fixture(scope="session", autouse=True)
async def setup_database():
    """Create all tables once per test session."""
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    yield
    await test_engine.dispose()


# conftest.py
@pytest.fixture
async def db_session():
    async with test_engine.connect() as conn:
        # Begin a nested transaction
        trans = await conn.begin()
        nested = await conn.begin_nested()
        async_session = AsyncSession(bind=conn, expire_on_commit=False)
        try:
            yield async_session
        finally:
            await async_session.close()
            await nested.rollback()
            await trans.rollback()
