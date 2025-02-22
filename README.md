# template-project

A template project for building a FastAPI application that uses UV for dependency management.

## Features

- Uses UV for dependency management
- Uses Docker for containerization
- Uses Makefile for development commands

## Development

To start the development container, run:

```bash
make run-dev
```

You can then see the swagger UI at [http://localhost:8000/docs](http://localhost:8000/docs)

To stop the development container, run:

```bash
make down
```

To run tests, run:

```bash
make test
```

To execute a shell inside the development container, run:

```bash
make shell-dev
```