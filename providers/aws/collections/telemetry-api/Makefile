# Terraform module task runner.
#
# Task definitions are delivered as packages by mpm and included from
# $(PACKAGES_DIR) below. Bootstrap a fresh checkout with:
#
#     make mpm-configure
#
# mpm resolves this module's .mpm manifest (and its .mpm.lock) through its own
# native config discovery -- no env file is included by make.

MPM ?= mpm
MPM_URL ?= https://github.com/matthew-dresden/mpm
MPM_VERSION ?= v1.0.0
MPM_CATALOG_SOURCE ?= https://github.com/matthew-dresden/mpm.git@1.0.0

# mpm always aggregates resolved packages into .packages/ at the manifest root.
PACKAGES_DIR ?= .packages

MPM_MANIFEST := $(firstword $(wildcard .mpm))
ifeq (,$(MPM_MANIFEST))
$(error Error: no .mpm manifest found in this module. Install mpm with 'pipx install git+$(MPM_URL)@$(MPM_VERSION)' then run 'mpm add terraform-module-build --catalog-source $(MPM_CATALOG_SOURCE)')
endif

ASDF_URL ?= https://github.com/asdf-vm/asdf.git
ASDF_VERSION ?= v0.15.0
ASDF_DIR ?= $$HOME/.asdf
TOOL_VERSIONS_FILE ?= .tool-versions
DEFAULT_PYTHON_VERSION ?= 3.12.9

IS_PIPELINE ?= false
JOB_NAME ?= job
JOB_EMAIL ?= job@job.job

# Include project level defaults (env vars, etc.)
-include Makefile.includes

# Include all package Makefiles delivered by `mpm install`
-include $(PACKAGES_DIR)/*/Makefile

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available make targets
	@echo "Available targets:"
	@$(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | uniq | \
		grep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: mpm-clean
mpm-clean:
	@$(MPM) clean
	@echo "Removed mpm state ($(PACKAGES_DIR)/ and .mpm-data/)"

.PHONY: mpm-configure
mpm-configure: mpm-install-asdf mpm-install-tools mpm-install-cli
	@ASDF_DIR=$(ASDF_DIR) && . $$ASDF_DIR/asdf.sh && \
	if ! command -v $(MPM) > /dev/null 2>&1; then \
		echo "Error: mpm not found after installation"; \
		exit 1; \
	fi && \
	echo "Using $$($(MPM) --version)" && \
	$(MPM) install || { echo "Error: mpm install failed"; exit 1; }

.PHONY: mpm-install-asdf
mpm-install-asdf:
	@if [ -d "$(ASDF_DIR)" ]; then \
		echo "asdf already installed at $(ASDF_DIR)"; \
	else \
		echo "Installing asdf $(ASDF_VERSION)..."; \
		git clone $(ASDF_URL) $(ASDF_DIR) --branch $(ASDF_VERSION) || { echo "Error: Failed to clone asdf"; exit 1; }; \
		echo "asdf installed successfully"; \
	fi
	@if [ ! -f "$(TOOL_VERSIONS_FILE)" ]; then \
		echo "Creating $(TOOL_VERSIONS_FILE) with python $(DEFAULT_PYTHON_VERSION)..."; \
		echo "python $(DEFAULT_PYTHON_VERSION)" > $(TOOL_VERSIONS_FILE); \
	else \
		if ! grep -q "^python" $(TOOL_VERSIONS_FILE); then \
			echo "Adding python $(DEFAULT_PYTHON_VERSION) to $(TOOL_VERSIONS_FILE)..."; \
			echo "python $(DEFAULT_PYTHON_VERSION)" >> $(TOOL_VERSIONS_FILE); \
		fi; \
	fi

.PHONY: mpm-install-cli
mpm-install-cli:
	@ASDF_DIR=$(ASDF_DIR) && . $$ASDF_DIR/asdf.sh && \
	if command -v $(MPM) > /dev/null 2>&1; then \
		echo "mpm already installed: $$($(MPM) --version)"; \
	else \
		echo "Installing mpm $(MPM_VERSION)..." && \
		pipx install "git+$(MPM_URL)@$(MPM_VERSION)" || { echo "Error: Failed to install mpm"; exit 1; } && \
		asdf reshim python && \
		echo "mpm installed successfully"; \
	fi

.PHONY: mpm-install-tools
mpm-install-tools:
	@if [ ! -d "$(ASDF_DIR)" ]; then \
		echo "Error: asdf not installed. Run 'make mpm-install-asdf' first."; \
		exit 1; \
	fi
	@if [ ! -f "$(TOOL_VERSIONS_FILE)" ]; then \
		echo "Error: $(TOOL_VERSIONS_FILE) not found. Run 'make mpm-install-asdf' first."; \
		exit 1; \
	fi
	@ASDF_DIR=$(ASDF_DIR) && . $$ASDF_DIR/asdf.sh && \
	awk '{print $$1}' $(TOOL_VERSIONS_FILE) | sort -u | while read plugin; do \
		if ! asdf plugin list | grep -q "^$$plugin$$"; then \
			echo "Installing asdf plugin: $$plugin"; \
			asdf plugin add $$plugin || { echo "Error: Failed to add plugin $$plugin"; exit 1; }; \
		fi; \
	done && \
	echo "Installing tools from $(TOOL_VERSIONS_FILE)..." && \
	asdf install || { echo "Error: Failed to install tools"; exit 1; } && \
	echo "Tools installed successfully"

.PHONY: mpm-list
mpm-list:
	@$(MPM) list

.PHONY: mpm-validate
mpm-validate:
	@$(MPM) validate lockfile
