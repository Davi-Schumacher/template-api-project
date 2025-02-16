# Define variables
COMPOSE=docker-compose
DEV_IMAGE=template-project-dev
PROD_IMAGE=template-project-prod
SERVICE_DEV=template_project_dev
SERVICE_PROD=template_project_prod

# ===== BUILD =====
# Build the production image
build-prod:
	docker build --target production -t $(PROD_IMAGE) .

# Build the development image (with dev dependencies)
build-dev:
	docker build --target dev -t $(DEV_IMAGE) .

# ===== RUN CONTAINERS =====
# Run the production container
run-prod:
	docker run -p 8000:8000 --name $(SERVICE_PROD) $(PROD_IMAGE)

# Run the development container with auto-reload
run-dev:
	docker run -p 8000:8000 --name $(SERVICE_DEV) $(DEV_IMAGE)

# ===== DEVELOPMENT COMMANDS =====
# Start a bash shell inside the dev container
shell-dev:
	docker exec -it $(SERVICE_DEV) bash

# Start a bash shell inside the production container
shell-prod:
	docker exec -it $(SERVICE_PROD) bash

# Install dependencies inside the dev container
install-dev:
	docker exec -it $(SERVICE_DEV) uv sync --frozen

# Tail logs from the dev container
logs-dev:
	docker logs -f $(SERVICE_DEV)

# Tail logs from the prod container
logs-prod:
	docker logs -f $(SERVICE_PROD)

# Stop and remove all containers
down:
	docker rm -f $(SERVICE_DEV) $(SERVICE_PROD) || true

# Clean up unused Docker resources
clean:
	docker system prune -f

test:
	docker exec -it $(SERVICE_DEV) bash -c "pytest ."
