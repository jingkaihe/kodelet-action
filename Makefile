.PHONY: help validate test test-local clean lint check-files logs release setup-act
.DEFAULT_GOAL := help

# Variables
ANTHROPIC_API_KEY ?= test-key
WORKFLOW ?= test.yml
RUN_ID ?= latest

help: ## Show this help message
	@echo "Kodelet Action - Common Development Tasks"
	@echo ""
	@echo "Version Management:"
	@echo "  make version              - Show current version"
	@echo "  make set-version VERSION=v1.2.3 - Set new version"
	@echo "  make release              - Create release using VERSION.txt"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

validate: ## Validate action.yml syntax and structure
	@echo "Validating action.yml syntax..."
	@python3 -c "import yaml; yaml.safe_load(open('action.yml'))" && echo "✓ YAML syntax valid"
	@echo "Checking required files..."
	@test -f action.yml && echo "✓ action.yml exists"
	@test -f README.md && echo "✓ README.md exists"
	@test -f LICENSE && echo "✓ LICENSE exists"
	@echo "✓ All validation checks passed"

check-files: ## Check if all required files exist
	@test -f action.yml && test -f README.md && test -f LICENSE && echo "✓ All required files present"

lint: ## Run YAML linting on action files
	@echo "Linting YAML files..."
	@find . -name "*.yml" -o -name "*.yaml" | grep -v node_modules | xargs -I {} sh -c 'echo "Checking: {}"; python3 -c "import yaml; yaml.safe_load(open(\"{}\"))"'

test: ## Run GitHub Actions tests (requires GitHub CLI)
	@echo "Running GitHub Actions workflow tests..."
	@gh workflow run $(WORKFLOW)
	@echo "✓ Test workflow triggered. Check status with 'make logs'"

test-local: ## Run local tests using act (requires act tool and ANTHROPIC_API_KEY)
	@echo "Running local tests with act..."
	@command -v act >/dev/null 2>&1 || { echo "Error: 'act' tool not found. Install from https://github.com/nektos/act"; exit 1; }
	@act push --secret ANTHROPIC_API_KEY=$(ANTHROPIC_API_KEY)

setup-act: ## Install act tool for local GitHub Actions testing
	@echo "Installing act tool..."
	@curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

logs: ## View GitHub Actions workflow logs
	@echo "Fetching workflow logs..."
	@gh run list --workflow=$(WORKFLOW) --limit=5
	@echo ""
	@echo "To view specific run logs, use: gh run view <run-id> --log"

logs-latest: ## View logs for the latest workflow run
	@echo "Fetching latest workflow logs..."
	@gh run view --log

status: ## Check status of recent workflow runs
	@echo "Recent workflow runs:"
	@gh run list --limit=10

release: ## Create a new release (reads version from VERSION.txt)
	@VERSION=$$(cat VERSION.txt | tr -d '\n'); \
	if [ -z "$$VERSION" ]; then echo "Error: VERSION.txt is empty or missing"; exit 1; fi; \
	echo "Creating release $$VERSION..."; \
	git tag $$VERSION; \
	git push origin $$VERSION; \
	echo "✓ Release $$VERSION created. Check status with 'make status'"

release-list: ## List recent releases
	@echo "Recent releases:"
	@gh release list --limit=10

version: ## Show current version from VERSION.txt
	@cat VERSION.txt

set-version: ## Set version in VERSION.txt (requires VERSION variable)
	@if [ -z "$(VERSION)" ]; then echo "Error: VERSION not set. Use: make set-version VERSION=v1.2.3"; exit 1; fi
	@echo "$(VERSION)" > VERSION.txt
	@echo "✓ Version set to $(VERSION)"

dev-setup: ## Setup development environment
	@echo "Setting up development environment..."
	@command -v gh >/dev/null 2>&1 || { echo "Installing GitHub CLI..."; curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg; echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null; sudo apt update; sudo apt install gh; }
	@command -v python3 >/dev/null 2>&1 || { echo "Installing Python3..."; sudo apt update; sudo apt install python3; }
	@echo "✓ Development environment ready"

clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@find . -name "*.tmp" -delete
	@find . -name "*.log" -delete
	@echo "✓ Cleanup complete"

dry-run: ## Test action in dry-run mode (requires local Kodelet)
	@echo "Running action in dry-run mode..."
	@KODELET_DRY_RUN=true ./action.yml

# Quick shortcuts
v: validate  ## Shortcut for validate
t: test      ## Shortcut for test
l: logs      ## Shortcut for logs
s: status    ## Shortcut for status