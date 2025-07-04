from typing import Optional

from pydantic import BaseModel, EmailStr


class UserName(BaseModel):
    name: str
    fullname: Optional[str] = None


class UserRequest(UserName):
    email_address: EmailStr


class AddressResponse(BaseModel):
    id: int
    email_address: EmailStr


class UserResponse(UserName):
    id: int
    addresses: list[AddressResponse]
