SHELL = /bin/bash

BIN_DIR = /usr/local/bin
TOOL_NAME = swift-doc-coverage
LIB_NAME = lib_InternalSwiftSyntaxParser.dylib
BUILD_DIR = .build
SOURCES = $(wildcard Sources/**/*.swift)

$(BUILD_DIR)/release/$(TOOL_NAME): $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox

.PHONY: install
install: $(BUILD_DIR)/release/$(TOOL_NAME)
	@install "$(BUILD_DIR)/release/$(TOOL_NAME)" $(BIN_DIR)
	@install "$(BUILD_DIR)/release/$(LIB_NAME)" $(BIN_DIR)

.PHONY: uninstall
uninstall:
	@rm -rf "$(BIN_DIR)/$(TOOL_NAME)"
	@rm -rf "$(BIN_DIR)/$(LIB_NAME)"

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
