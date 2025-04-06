.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Define variables
DC=docker compose
SERVICE_DEV=template_project_dev
SERVICE_PROD=template_project_prod
export COMPOSE_BAKE=true

# ===== BUILD =====
build-prod:  ## Build the production image
	$(DC) build prod

build-dev:  ## Build the development image (with dev dependencies)
	$(DC) build dev

rebuild-dev:  ## Build the development image with no cache
	$(DC) build dev --no-cache

# ===== RUN CONTAINERS =====
start-dev-db:  ## Run the development database container
	$(DC) up dev_db -d --build

run-prod:  ## Run the production container
	$(DC) up prod -d --build

run-dev: start-dev-db  ## Run the development container with auto-reload
	$(DC) up dev -d --build

run-dev-pytest: start-dev-db  ## Run the pytest container with debug
	$(DC) up dev_debug_pytest -d --build

wipe-db:  ## Wipe the database by removing the volume and recreating it
	$(DC) down -v
	@echo "Database has been wiped. Run 'make run-dev' to start fresh."

# ===== DEVELOPMENT COMMANDS =====
shell-dev:  ## Start a bash shell inside the dev container
	@$(DC) exec dev bash 2>/dev/null || ($(DC) up dev -d --build && $(DC) exec dev bash)

shell-prod:  ## Start a bash shell inside the production container
	@$(DC) exec prod bash 2>/dev/null || ($(DC) up prod -d --build && $(DC) exec prod bash)

logs-dev:  ## Tail logs from the dev container
	$(DC) logs -f dev

logs-prod:  ## Tail logs from the prod container
	$(DC) logs -f prod

down:  ## Stop and remove all containers
	$(DC) down

clean:  ## Clean up unused Docker resources
	docker system prune -f

format:  ## Run formatting
	$(DC) run --rm -T dev uv run ruff format src tests
	$(DC) stop dev

lint:  ## Run linting
	$(DC) run --rm -T dev uv run ruff check --select I --fix src tests
	$(DC) stop dev

pytest: start-dev-db  ## Run pytest
	$(DC) run --rm -T dev pytest tests
	$(DC) stop dev_db

pytest-debug: start-dev-db run-dev-pytest  ## Run pytest with debug
	$(DC) exec dev_debug_pytest python -m debugpy --listen 0.0.0.0:5679 --wait-for-client -m pytest tests
	$(DC) stop dev_debug_pytest
	$(DC) stop dev_db

mypy:  ## Run mypy type checking
	$(DC) run --rm -T dev mypy src tests
	$(DC) stop dev

ci:  ## Run CI checks
	$(DC) run --rm -T dev sh -c "\
		uv run ruff format src tests && \
		uv run ruff check --select I src tests && \
		uv run mypy src tests && \
		uv run pytest tests"
	$(DC) stop dev