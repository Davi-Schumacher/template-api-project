from typing import Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr


class UserName(BaseModel):
    name: str
    fullname: Optional[str] = None


class UserRequest(UserName):
    email_address: EmailStr


class AddressResponse(BaseModel):
    id: UUID
    email_address: EmailStr


class UserResponse(UserName):
    id: UUID
    addresses: list[AddressResponse]
