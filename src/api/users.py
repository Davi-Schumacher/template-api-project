from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Body, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from src.db.models import Address, User
from src.db.session import get_async_session
from src.schemas.user import UserRequest, UserResponse

user_router = APIRouter(prefix="/users", tags=["users"])


@user_router.get("/")
async def get_users(
    num_results: int = Query(
        default=10, ge=1, le=10, description="Number of results to return (1-10)"
    ),
    session: AsyncSession = Depends(get_async_session),
) -> list[UserResponse]:
    users = await session.execute(
        select(User).options(selectinload(User.addresses)).limit(num_results)
    )
    return [
        UserResponse.model_validate(user, from_attributes=True)
        for user in users.scalars().all()
    ]


@user_router.post("/")
async def create_user(
    user: Annotated[
        UserRequest,
        Body(
            examples=[
                UserRequest(
                    name="sandy123",
                    fullname="Sandy Cheeks",
                    email_address="sandy@example.com",
                )
            ]
        ),
    ],
    session: AsyncSession = Depends(get_async_session),
) -> UserResponse:
    db_user = User(**user.model_dump(exclude={"email_address"}))
    db_address = Address(email_address=user.email_address)
    db_user.addresses.append(db_address)

    session.add(db_user)
    await session.commit()

    return UserResponse.model_validate(db_user, from_attributes=True)


@user_router.get("/{user_id}")
async def get_user_account_info(
    user_id: UUID, session: AsyncSession = Depends(get_async_session)
) -> UserResponse:
    user = await session.execute(
        select(User).options(selectinload(User.addresses)).filter(User.id == user_id)
    )
    return UserResponse.model_validate(user.scalar_one(), from_attributes=True)
