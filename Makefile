SHELL = /bin/bash

BIN_DIR = /usr/local/bin
NAME = $(shell basename $$PWD)
BUILD_DIR = $(shell pwd)/.build
SOURCES = $(wildcard Sources/**/*.swift)

$(BUILD_DIR)/release/$(NAME): $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILD_DIR)"

.PHONY: install
install: $(BUILD_DIR)/release/$(NAME)
	@install -d $(BIN_DIR)
	@install "$(BUILD_DIR)/release/$(NAME)" $(BIN_DIR)

.PHONY: uninstall
uninstall:
	@rm -rf "$(BIN_DIR)/$(NAME)"

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
