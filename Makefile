.PHONY: help build build-cli build-all run run-cli clean clean-all test shell

# Default music directory
MUSIC_DIR ?= $(HOME)/Music

help:
	@echo "Kid3 Docker Container - Available targets:"
	@echo ""
	@echo "  make build         - Build Kid3 with GUI and CLI (default)"
	@echo "  make build-cli     - Build lightweight CLI-only version"
	@echo "  make build-all     - Build both GUI and CLI versions"
	@echo ""
	@echo "  make run           - Run Kid3 GUI"
	@echo "  make run-cli       - Run Kid3 CLI (interactive)"
	@echo "  make shell         - Open bash shell in container"
	@echo ""
	@echo "  make test          - Test CLI version"
	@echo "  make clean         - Remove containers and images"
	@echo "  make clean-all     - Remove everything including volumes"
	@echo ""
	@echo "Environment variables:"
	@echo "  MUSIC_DIR          - Music directory to mount (default: $(HOME)/Music)"
	@echo ""
	@echo "Examples:"
	@echo "  make run"
	@echo "  make run-cli MUSIC_DIR=/path/to/music"

build:
	@echo "Building Kid3 with GUI and CLI support..."
	docker build -t kid3:latest .

build-cli:
	@echo "Building Kid3 CLI-only version..."
	docker build -f Dockerfile.cli -t kid3:cli .

build-all: build build-cli

run: build
	@echo "Launching Kid3 GUI..."
	@echo "Music directory: $(MUSIC_DIR)"
	@if [ ! -d "$(MUSIC_DIR)" ]; then \
		echo "Error: Music directory does not exist: $(MUSIC_DIR)"; \
		exit 1; \
	fi
	@xhost +local:docker 2>/dev/null || true
	docker run -it --rm \
		--name kid3-gui \
		-e DISPLAY=$(DISPLAY) \
		-e QT_X11_NO_MITSHM=1 \
		-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
		-v "$(MUSIC_DIR):/music" \
		-v kid3-config:/home/kid3user/.config \
		kid3:latest kid3-qt

run-cli: build
	@echo "Launching Kid3 CLI..."
	@echo "Music directory: $(MUSIC_DIR)"
	@if [ ! -d "$(MUSIC_DIR)" ]; then \
		echo "Error: Music directory does not exist: $(MUSIC_DIR)"; \
		exit 1; \
	fi
	docker run -it --rm \
		--name kid3-cli \
		-v "$(MUSIC_DIR):/music" \
		-v kid3-config:/home/kid3user/.config \
		kid3:latest kid3-cli

shell: build
	@echo "Opening shell in Kid3 container..."
	docker run -it --rm \
		-v "$(MUSIC_DIR):/music" \
		kid3:latest /bin/bash

test: build-cli
	@echo "Testing Kid3 CLI version..."
	docker run --rm kid3:cli kid3-cli --help
	@echo ""
	@echo "✓ CLI version works!"

clean:
	@echo "Cleaning up containers and images..."
	-docker stop kid3-gui kid3-cli 2>/dev/null || true
	-docker rm kid3-gui kid3-cli 2>/dev/null || true
	-docker rmi kid3:latest kid3:cli 2>/dev/null || true
	@echo "Cleanup complete!"

clean-all: clean
	@echo "Removing volumes..."
	-docker volume rm kid3-config 2>/dev/null || true
	@echo "Full cleanup complete!"

# Docker Compose targets
compose-up:
	@xhost +local:docker 2>/dev/null || true
	MUSIC_DIR=$(MUSIC_DIR) docker compose up

compose-down:
	docker compose down

compose-build:
	docker compose build

compose-clean:
	docker compose down -v
