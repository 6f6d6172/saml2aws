NAME=saml2aws
ARCH=$(shell uname -m)
VERSION=2.28.0
ITERATION := 1

GOLANGCI_VERSION = 1.45.2
GORELEASER_VERSION = 0.157.0

SOURCE_FILES?=$$(go list ./... | grep -v /vendor/)
TEST_PATTERN?=.
TEST_OPTIONS?=

BIN_DIR := ./bin

ci: prepare test

#$(BIN_DIR)/golangci-lint: $(BIN_DIR)/golangci-lint-${GOLANGCI_VERSION}
#	@ln -sf golangci-lint-${GOLANGCI_VERSION} $(BIN_DIR)/golangci-lint
#$(BIN_DIR)/golangci-lint-${GOLANGCI_VERSION}:
#	@curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | BINARY=golangci-lint bash -s -- v${GOLANGCI_VERSION}
#	@mv $(BIN_DIR)/golangci-lint $@
#
#$(BIN_DIR)/goreleaser: $(BIN_DIR)/goreleaser-${GORELEASER_VERSION}
#	@ln -sf goreleaser-${GORELEASER_VERSION} $(BIN_DIR)/goreleaeer
#$(BIN_DIR)/goreleaser-${GORELEASER_VERSION}:
#	@curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | BINARY=goreleaser bash -s -- v${GORELEASER_VERSION}
#	@mv $(BIN_DIR)/goreleaser $@

mod:
	@go mod download
	@go mod tidy
.PHONY: mod

lint: 
	@echo "--- lint all the things"
	@docker run --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:v$(GOLANGCI_VERSION) golangci-lint run -v
.PHONY: lint

lint-fix:
	@echo "--- lint all the things"
	@docker run --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:v$(GOLANGCI_VERSION) golangci-lint run -v --fix
.PHONY: lint-fix

fmt: lint-fix

install:
	go install ./cmd/saml2aws
.PHONY: mod

build:
	goreleaser build --snapshot --rm-dist
.PHONY: build

clean:
	@rm -fr ./build
.PHONY: clean

generate-mocks:
	mockery -dir pkg/prompter --all
	mockery -dir pkg/provider/okta -name U2FDevice
.PHONY: generate-mocks

test:
	@echo "--- test all the things"
	@go test -cover ./...
.PHONY: test
