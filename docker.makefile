# Docker-specific Makefile that handles legacy peer deps
# This extends the main makefile with Docker-friendly npm commands

include makefile

# Override npm commands to use legacy-peer-deps
.PHONY: docker-npm
docker-npm:
	$(npm) ci --legacy-peer-deps
	$(npm) run build

.PHONY: docker-npm-dev
docker-npm-dev:
	$(npm) ci --legacy-peer-deps
	$(npm) run dev

.PHONY: docker-install
docker-install:
	$(npm) install --legacy-peer-deps

.PHONY: docker-build
docker-build: docker-install
	$(npm) run build

.PHONY: docker-dev
docker-dev: docker-install
	$(npm) run dev

# For make targets that need dependencies installed first
.PHONY: docker-appstore
docker-appstore: docker-install appstore
