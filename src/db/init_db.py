from src.db.models import Base
from src.db.session import engine


async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


if __name__ == "__main__":
    import asyncio

    asyncio.run(init_db())
