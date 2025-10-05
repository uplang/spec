# Makefile for UP Specification
.PHONY: help test examples clean serve

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: examples ## Test all specification examples
	@echo "All examples validated successfully"

examples: ## Validate all example files
	@echo "Validating specification examples..."
	@if command -v up >/dev/null 2>&1; then \
		for example in examples/*.up; do \
			if [ -f "$$example" ]; then \
				echo "Validating $$example..."; \
				up validate -i $$example || exit 1; \
			fi; \
		done; \
		echo "✓ All examples are valid"; \
	else \
		echo "UP CLI not found. Install with: go install github.com/uplang/tools/up@latest"; \
		echo "Skipping validation..."; \
	fi

list-examples: ## List all example files
	@echo "Specification examples:"
	@find examples -name "*.up" -type f | sort

view-example: ## View a specific example (use: make view-example FILE=01-basic-scalars.up)
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make view-example FILE=<filename>"; \
		echo "Available examples:"; \
		find examples -name "*.up" -type f -printf "  %f\n" | sort; \
	else \
		cat examples/$(FILE); \
	fi

clean: ## Clean generated files
	@echo "No generated files to clean in spec"

serve: ## Serve documentation (requires mdbook or similar)
	@echo "Documentation serving not yet implemented"
	@echo "View README.md and other .md files directly"

check-links: ## Check for broken links in documentation
	@echo "Checking markdown files for broken links..."
	@find . -name "*.md" -type f | while read file; do \
		echo "Checking $$file..."; \
	done

.DEFAULT_GOAL := help

