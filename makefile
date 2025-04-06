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

# Build the development image with no cache
rebuild-dev:
	$(DC) build dev --no-cache

# Build the development database
build-dev-db:
	$(DC) build dev_db

# Build the development database with no cache
rebuild-dev-db:
	$(DC) build dev_db --no-cache

# ===== RUN CONTAINERS =====
start-dev-db:
	$(DC) up dev_db -d --build

# Run the production container
run-prod:
	$(DC) up prod -d --build

# Run the development container with auto-reload
run-dev: start-dev-db
	$(DC) up dev -d --build

# Wipe the database by removing the volume and recreating it
wipe-db:
	$(DC) down -v
	@echo "Database has been wiped. Run 'make run-dev' to start fresh."

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
	$(DC) exec -T dev uv run ruff check --select I --fix src tests
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
		uv run ruff check --select I src tests && \
		uv run mypy src tests && \
		uv run pytest tests"
	$(DC) stop dev
