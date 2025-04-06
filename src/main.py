from fastapi import FastAPI

from src.api.users import user_router

app = FastAPI()

app.include_router(user_router)


@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI with UV!"}
