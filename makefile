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

# Run tests
test:
	$(DC) up dev -d --build
	$(DC) exec -T dev pytest .
	$(DC) stop dev
