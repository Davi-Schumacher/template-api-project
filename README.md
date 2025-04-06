# template-project

A template project for building a FastAPI application.

## Features

- Uses UV for dependency management
- Uses Docker for containerization
- Uses Makefile for development commands

## Requirements

- Docker (one of the two setups below)

  - [Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)
  - [Docker Desktop](https://docs.docker.com/desktop/)

- [uv](https://docs.astral.sh/uv/getting-started/installation/)

## Development

To start the development container, run:

```bash
make run-dev
```

You can then see the swagger UI at [http://localhost:8000/docs](http://localhost:8000/docs). The `/src` and `/tests` directories are mounted into the container, so you can edit the code and run the tests live.

To execute a shell inside the development container, run:

```bash
make shell-dev
```

To stop the development container, run:

```bash
make down
```

To run ci checks including lint, format, types, and tests, run:

```bash
make ci
```
