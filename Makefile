# Makefile for backup-vscodium
# Automates testing, linting, and installation

.PHONY: help test integration lint install version

# Default target
help:
	@echo "Backup VScodium Automation"
	@echo "=========================="
	@echo "Available commands:"
	@echo "  make test         - Run unit tests"
	@echo "  make integration  - Run integration tests"
	@echo "  make lint         - Run shellcheck on scripts (if available)"
	@echo "  make install      - Symlink scripts to ~/.local/bin"
	@echo "  make version      - Show script versions"
	@echo "  make help         - Show this help message"

test:
	@echo "Running unit tests..."
	@bash tests/test-all.sh

integration:
	@echo "Running integration tests..."
	@bash tests/integration-tests.sh

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Running shellcheck..."; \
		shellcheck -x backup-codium.sh restore-codium.sh tests/test-all.sh; \
	else \
		echo "Error: shellcheck is not installed. Please install it to lint scripts."; \
		exit 1; \
	fi

install:
	@echo "Installing scripts to ~/.local/bin..."
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(PWD)/backup-codium.sh $(HOME)/.local/bin/backup-codium
	@ln -sf $(PWD)/restore-codium.sh $(HOME)/.local/bin/restore-codium
	@echo "Successfully installed to ~/.local/bin"
	@echo "Make sure ~/.local/bin is in your PATH."

version:
	@echo "backup-codium.sh: "
	@./backup-codium.sh --version
	@echo "restore-codium.sh: "
	@./restore-codium.sh --version
