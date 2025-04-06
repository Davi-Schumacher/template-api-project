# Define variables
DC=docker compose
SERVICE_DEV=template_project_dev
SERVICE_PROD=template_project_prod
export COMPOSE_BAKE=true

# ===== BUILD =====
# Build the production image
build-prod:
	$(DC) build prod

# Build the development image (with dev dependencies)
build-dev:
	$(DC) build dev

# ===== RUN CONTAINERS =====
# Run the production container
run-prod:
	$(DC) up prod -d --build

# Run the development container with auto-reload
run-dev:
	$(DC) up dev -d --build

# ===== DEVELOPMENT COMMANDS =====
# Start a bash shell inside the dev container
shell-dev:
	@$(DC) exec dev bash 2>/dev/null || ($(DC) up dev -d --build && $(DC) exec dev bash)

# Start a bash shell inside the production container
shell-prod:
	@$(DC) exec prod bash 2>/dev/null || ($(DC) up prod -d --build && $(DC) exec prod bash)

# Tail logs from the dev container
logs-dev:
	$(DC) logs -f dev

# Tail logs from the prod container
logs-prod:
	$(DC) logs -f prod

# Stop and remove all containers
down:
	$(DC) down

# Clean up unused Docker resources
clean:
	docker system prune -f

# Run formatting
format: run-dev
	$(DC) exec -T dev uv run ruff format src tests
	$(DC) stop dev

# Run linting
lint: run-dev
	$(DC) exec -T dev uv run ruff check src tests
	$(DC) stop dev

# Run pytest
pytest: run-dev
	$(DC) exec -T dev pytest tests
	$(DC) stop dev

# Run mypy type checking
mypy: run-dev
	$(DC) exec -T dev mypy src tests
	$(DC) stop dev

# Run CI checks
ci: run-dev
	$(DC) exec -T dev sh -c "\
		uv run ruff format src tests && \
		uv run ruff check src tests && \
		uv run mypy src tests && \
		uv run pytest tests"
	$(DC) stop dev
