# Define variables
DC=docker compose
SERVICE_DEV=template_project_dev
SERVICE_PROD=template_project_prod

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

# Run CI checks
ci: run-dev
	$(DC) exec -T dev black --check src tests
	$(DC) exec -T dev isort --check src tests
	$(DC) exec -T dev flake8 src tests
	$(DC) exec -T dev mypy src tests
	$(DC) exec -T dev pytest tests
	$(DC) stop dev

# Format code with black
black:
	$(DC) exec -T dev black src tests

# Sort imports with isort
isort:
	$(DC) exec -T dev isort --profile black src tests

# Run flake8 linting
flake8:
	$(DC) exec -T dev flake8 src tests

# Run mypy type checking
mypy:
	$(DC) exec -T dev mypy src tests

# Run pytest
pytest:
	$(DC) exec -T dev pytest tests

# Run all formatting
format: black isort
