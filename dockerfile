# ======= BUILDER STAGE =======
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PYTHON_DOWNLOADS=0

WORKDIR /app

# Cache UV dependencies to optimize builds
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# ======= DEVELOPMENT STAGE =======
FROM builder AS dev

# Copy the entire project for development
COPY . .

# Install all dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Expose the API port
EXPOSE 8000

# Start FastAPI with auto-reload for development
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ======= PRODUCTION STAGE =======
FROM builder AS production

# Ensure compatibility with the builder's Python environment
ENV PATH="/app/.venv/bin:$PATH"

# Copy only the virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Copy only the source code needed for production
COPY src/ ./src/

# Expose the API port
EXPOSE 8000

# Start FastAPI for production (no reload)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]