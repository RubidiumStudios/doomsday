BUILD_TARGET ?= cmd/*.go
APP_NAME ?= doomsday
OUTPUT_NAME ?= $(APP_NAME)
SHELL := $(shell which bash)
COMMIT_HASH := $(shell git log --pretty='format:%h' -n 1)
DIRTY_LINE := $(shell git diff --shortstat 2> /dev/null | tail -n1)
ifneq ("$(DIRTY_LINE)", "")
  DIRTY := +
endif
VERSION ?= development
LDFLAGS := -X "main.Version=$(VERSION)-$(COMMIT_HASH)$(DIRTY)"
BUILD := go build -ldflags='$(LDFLAGS)' -o $(OUTPUT_NAME) $(BUILD_TARGET)

.PHONY: build server darwin darwin-amd64 darwin-arm64 linux linux-amd64 embed tsc all clean
.DEFAULT: build

build: embed server

server:
	@echo $(VERSION)-$(COMMIT_HASH)$(DIRTY)
	GOOS=$(GOOS) GOARCH=$(GOARCH) VERSION=$(VERSION) $(BUILD)

darwin: darwin-amd64 darwin-arm64

darwin-amd64:
	GOOS=darwin GOARCH=amd64 OUTPUT_NAME=releases/$(APP_NAME)-darwin-amd64 $(MAKE) server

darwin-arm64:
	GOOS=darwin GOARCH=arm64 OUTPUT_NAME=releases/$(APP_NAME)-darwin-arm64 $(MAKE) server

linux: linux-amd64 linux-arm64

linux-amd64:
	GOOS=linux GOARCH=amd64 OUTPUT_NAME=releases/$(APP_NAME)-linux-amd64 $(MAKE) server

linux-arm64:
	GOOS=linux GOARCH=arm64 OUTPUT_NAME=releases/$(APP_NAME)-linux-arm64 $(MAKE) server

all: embed darwin linux

embed: tsc
	GOOS="" GOARCH="" go run web/embed/main.go web/embed/mappings.yml

tsc:
	cd web && npm install && npx tsc --project tsconfig.json

clean:
	rm -rf $(APP_NAME) releases
