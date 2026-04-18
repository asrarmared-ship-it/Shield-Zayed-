# ═══════════════════════════════════════════════════════════════════════════
# 🛡️ ZAYED CYBERSHIELD - PROFESSIONAL MAKEFILE
# ═══════════════════════════════════════════════════════════════════════════
# Project: Zayed CyberShield Protection System (درع زايد)
# Version: 2.0.0
# Author: asrar-mared (صائد الثغرات المحارب)
# Date: 2026-01-05
#
# Description:
#   Professional build system for Zayed CyberShield with full UTF-8 support,
#   dependency management, testing, and deployment automation.
#
# Usage:
#   make              - Build the project
#   make clean        - Remove build artifacts
#   make install      - Install system-wide
#   make uninstall    - Remove installation
#   make run          - Run the application
#   make test         - Run tests
#   make debug        - Build with debug symbols
#   make release      - Build optimized release
#   make help         - Show this help
#
# Requirements:
#   - GCC 9.0+ or Clang 10.0+
#   - GNU Make 4.0+
#   - ncursesw library
#   - libcurl
#   - json-c
#   - pthreads
#
# License: MIT with Security Addendum
# Copyright © 2026 Zayed CyberShield | asrar-mared
# ═══════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

# Project information
PROJECT_NAME = zayed-shield
VERSION = 2.0.0
AUTHOR = asrar-mared

# Compiler settings
CC = gcc
CXX = g++

# Standard flags
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -Wformat=2 \
         -Wno-unused-parameter -Wshadow -Wwrite-strings \
         -Wstrict-prototypes -Wold-style-definition \
         -Wredundant-decls -Wnested-externs -Wmissing-include-dirs

# Preprocessor flags
CPPFLAGS = -D_XOPEN_SOURCE=700 -D_GNU_SOURCE -DUTF8_SUPPORT \
           -DPROJECT_VERSION=\"$(VERSION)\" \
           -DPROJECT_AUTHOR=\"$(AUTHOR)\"

# Include directories
INCLUDES = -Iinclude

# Library flags
LDFLAGS = -L/usr/lib -L/usr/local/lib
LDLIBS = -lncursesw -lpthread -lcurl -ljson-c -lm

# Optimization flags (default: release)
OPTFLAGS = -O3 -march=native -flto

# Debug flags
DEBUGFLAGS = -O0 -g3 -ggdb -DDEBUG -fsanitize=address -fsanitize=undefined

# Security hardening flags
SECURITYFLAGS = -fstack-protector-strong -D_FORTIFY_SOURCE=2 \
                -Wformat-security -Werror=format-security \
                -fPIE -pie

# ═══════════════════════════════════════════════════════════════════════════
# DIRECTORIES
# ═══════════════════════════════════════════════════════════════════════════

SRCDIR = src
OBJDIR = obj
BINDIR = bin
TESTDIR = tests
DOCDIR = docs
LOGDIR = /var/log/$(PROJECT_NAME)
INSTALLDIR = /usr/local/bin

# ═══════════════════════════════════════════════════════════════════════════
# FILES
# ═══════════════════════════════════════════════════════════════════════════

# Source files
SOURCES = $(wildcard $(SRCDIR)/*.c)
HEADERS = $(wildcard include/*.h)

# Object files
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

# Target binary
TARGET = $(BINDIR)/$(PROJECT_NAME)

# Test files
TEST_SOURCES = $(wildcard $(TESTDIR)/*.c)
TEST_OBJECTS = $(TEST_SOURCES:$(TESTDIR)/%.c=$(OBJDIR)/test_%.o)
TEST_TARGET = $(BINDIR)/test_$(PROJECT_NAME)

# ═══════════════════════════════════════════════════════════════════════════
# COLORS FOR OUTPUT (UTF-8 Emoji Support)
# ═══════════════════════════════════════════════════════════════════════════

COLOR_RESET = \033[0m
COLOR_BOLD = \033[1m
COLOR_RED = \033[31m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_BLUE = \033[34m
COLOR_CYAN = \033[36m

# Emoji
EMOJI_BUILD = 🔨
EMOJI_CLEAN = 🧹
EMOJI_SUCCESS = ✅
EMOJI_ERROR = ❌
EMOJI_INSTALL = 📦
EMOJI_RUN = 🚀
EMOJI_TEST = 🧪
EMOJI_SHIELD = 🛡️
EMOJI_WARRIOR = ⚔️

# ═══════════════════════════════════════════════════════════════════════════
# PHONY TARGETS
# ═══════════════════════════════════════════════════════════════════════════

.PHONY: all clean install uninstall run test debug release help \
        check-deps setup version banner info dirs

# ═══════════════════════════════════════════════════════════════════════════
# DEFAULT TARGET
# ═══════════════════════════════════════════════════════════════════════════

all: banner dirs $(TARGET)
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Build complete: $(TARGET)$(COLOR_RESET)"
	@echo "$(COLOR_CYAN)Run with: make run$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# BANNER
# ═══════════════════════════════════════════════════════════════════════════

banner:
	@echo "$(COLOR_CYAN)"
	@echo "╔═══════════════════════════════════════════════════════════╗"
	@echo "║  $(EMOJI_SHIELD)  ZAYED CYBERSHIELD - BUILD SYSTEM $(EMOJI_WARRIOR)       ║"
	@echo "║           درع زايد للأمن السيبراني                      ║"
	@echo "╚═══════════════════════════════════════════════════════════╝"
	@echo "$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Version: $(VERSION)$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Author:  $(AUTHOR)$(COLOR_RESET)"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════
# CREATE DIRECTORIES
# ═══════════════════════════════════════════════════════════════════════════

dirs:
	@mkdir -p $(OBJDIR) $(BINDIR)

# ═══════════════════════════════════════════════════════════════════════════
# COMPILATION RULES
# ═══════════════════════════════════════════════════════════════════════════

# Compile object files
$(OBJDIR)/%.o: $(SRCDIR)/%.c $(HEADERS)
	@echo "$(COLOR_BLUE)$(EMOJI_BUILD) Compiling: $<$(COLOR_RESET)"
	@$(CC) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) $(OPTFLAGS) $(SECURITYFLAGS) -c $< -o $@

# Link target binary
$(TARGET): $(OBJECTS)
	@echo "$(COLOR_YELLOW)$(EMOJI_BUILD) Linking: $(TARGET)$(COLOR_RESET)"
	@$(CC) $(CFLAGS) $(OPTFLAGS) $(SECURITYFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)
	@strip $(TARGET) 2>/dev/null || true
	@chmod +x $(TARGET)

# ═══════════════════════════════════════════════════════════════════════════
# DEBUG BUILD
# ═══════════════════════════════════════════════════════════════════════════

debug: OPTFLAGS = $(DEBUGFLAGS)
debug: SECURITYFLAGS =
debug: clean dirs
	@echo "$(COLOR_YELLOW)$(EMOJI_BUILD) Building DEBUG version...$(COLOR_RESET)"
	@$(MAKE) --no-print-directory $(TARGET)
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Debug build complete$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# RELEASE BUILD
# ═══════════════════════════════════════════════════════════════════════════

release: OPTFLAGS = -O3 -march=native -flto -DNDEBUG
release: clean dirs
	@echo "$(COLOR_YELLOW)$(EMOJI_BUILD) Building RELEASE version...$(COLOR_RESET)"
	@$(MAKE) --no-print-directory $(TARGET)
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Release build complete$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# TESTING
# ═══════════════════════════════════════════════════════════════════════════

# Compile test object files
$(OBJDIR)/test_%.o: $(TESTDIR)/%.c $(HEADERS)
	@echo "$(COLOR_BLUE)$(EMOJI_TEST) Compiling test: $<$(COLOR_RESET)"
	@$(CC) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Build test suite
$(TEST_TARGET): $(TEST_OBJECTS) $(filter-out $(OBJDIR)/main.o, $(OBJECTS))
	@echo "$(COLOR_YELLOW)$(EMOJI_TEST) Linking tests: $(TEST_TARGET)$(COLOR_RESET)"
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

test: dirs $(TEST_TARGET)
	@echo "$(COLOR_CYAN)$(EMOJI_TEST) Running tests...$(COLOR_RESET)"
	@$(TEST_TARGET)
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) All tests passed$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════

install: $(TARGET)
	@echo "$(COLOR_YELLOW)$(EMOJI_INSTALL) Installing $(PROJECT_NAME)...$(COLOR_RESET)"
	@sudo cp $(TARGET) $(INSTALLDIR)/
	@sudo chmod 755 $(INSTALLDIR)/$(PROJECT_NAME)
	@sudo mkdir -p $(LOGDIR)
	@sudo chmod 755 $(LOGDIR)
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Installation complete$(COLOR_RESET)"
	@echo "$(COLOR_CYAN)Run with: $(PROJECT_NAME)$(COLOR_RESET)"

uninstall:
	@echo "$(COLOR_YELLOW)$(EMOJI_CLEAN) Uninstalling $(PROJECT_NAME)...$(COLOR_RESET)"
	@sudo rm -f $(INSTALLDIR)/$(PROJECT_NAME)
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Uninstallation complete$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# RUNNING
# ═══════════════════════════════════════════════════════════════════════════

run: $(TARGET)
	@echo "$(COLOR_CYAN)$(EMOJI_RUN) Running Zayed CyberShield...$(COLOR_RESET)"
	@export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && $(TARGET)

run-sudo: $(TARGET)
	@echo "$(COLOR_CYAN)$(EMOJI_RUN) Running with elevated privileges...$(COLOR_RESET)"
	@sudo LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 $(TARGET)

# ═══════════════════════════════════════════════════════════════════════════
# CLEANING
# ═══════════════════════════════════════════════════════════════════════════

clean:
	@echo "$(COLOR_YELLOW)$(EMOJI_CLEAN) Cleaning build artifacts...$(COLOR_RESET)"
	@rm -rf $(OBJDIR) $(BINDIR)
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Cleaned build artifacts$(COLOR_RESET)"

clean-logs:
	@echo "$(COLOR_YELLOW)$(EMOJI_CLEAN) Cleaning logs...$(COLOR_RESET)"
	@sudo rm -rf $(LOGDIR)/*
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Logs cleaned$(COLOR_RESET)"

clean-all: clean clean-logs
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Complete cleanup done$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# DEPENDENCY CHECKING
# ═══════════════════════════════════════════════════════════════════════════

check-deps:
	@echo "$(COLOR_CYAN)Checking dependencies...$(COLOR_RESET)"
	@command -v $(CC) >/dev/null 2>&1 || { echo "$(COLOR_RED)$(EMOJI_ERROR) gcc not found$(COLOR_RESET)"; exit 1; }
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) gcc: $$($(CC) --version | head -n1)$(COLOR_RESET)"
	@pkg-config --exists ncursesw || { echo "$(COLOR_RED)$(EMOJI_ERROR) ncursesw not found$(COLOR_RESET)"; exit 1; }
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) ncursesw: $$(pkg-config --modversion ncursesw)$(COLOR_RESET)"
	@pkg-config --exists libcurl || { echo "$(COLOR_RED)$(EMOJI_ERROR) libcurl not found$(COLOR_RESET)"; exit 1; }
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) libcurl: $$(pkg-config --modversion libcurl)$(COLOR_RESET)"
	@pkg-config --exists json-c || { echo "$(COLOR_RED)$(EMOJI_ERROR) json-c not found$(COLOR_RESET)"; exit 1; }
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) json-c: $$(pkg-config --modversion json-c)$(COLOR_RESET)"
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) All dependencies satisfied$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# SETUP & INSTALLATION OF DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════════════

setup:
	@echo "$(COLOR_CYAN)$(EMOJI_INSTALL) Setting up development environment...$(COLOR_RESET)"
	@if [ -f /etc/debian_version ]; then \
		echo "Detected Debian/Ubuntu"; \
		sudo apt-get update; \
		sudo apt-get install -y gcc make libncursesw5-dev libcurl4-openssl-dev libjson-c-dev locales; \
	elif [ -f /etc/redhat-release ]; then \
		echo "Detected RHEL/Fedora"; \
		sudo dnf install -y gcc make ncurses-devel libcurl-devel json-c-devel glibc-langpack-ar; \
	else \
		echo "$(COLOR_YELLOW)⚠️  Unknown OS. Install dependencies manually.$(COLOR_RESET)"; \
	fi
	@sudo locale-gen en_US.UTF-8 2>/dev/null || true
	@sudo locale-gen ar_AE.UTF-8 2>/dev/null || true
	@echo "$(COLOR_GREEN)$(EMOJI_SUCCESS) Setup complete$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════
# VERSION & INFO
# ═══════════════════════════════════════════════════════════════════════════

version:
	@echo "$(COLOR_CYAN)$(EMOJI_SHIELD) Zayed CyberShield v$(VERSION)$(COLOR_RESET)"

info:
	@echo "$(COLOR_CYAN)╔═══════════════════════════════════════════════════════════╗$(COLOR_RESET)"
	@echo "$(COLOR_CYAN)║  $(EMOJI_SHIELD)  ZAYED CYBERSHIELD - PROJECT INFO $(EMOJI_WARRIOR)         ║$(COLOR_RESET)"
	@echo "$(COLOR_CYAN)╚═══════════════════════════════════════════════════════════╝$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_YELLOW)Project:$(COLOR_RESET)     $(PROJECT_NAME)"
	@echo "$(COLOR_YELLOW)Version:$(COLOR_RESET)     $(VERSION)"
	@echo "$(COLOR_YELLOW)Author:$(COLOR_RESET)      $(AUTHOR)"
	@echo "$(COLOR_YELLOW)Compiler:$(COLOR_RESET)    $(CC) $$($(CC) -dumpversion)"
	@echo "$(COLOR_YELLOW)Sources:$(COLOR_RESET)     $(words $(SOURCES)) files"
	@echo "$(COLOR_YELLOW)Objects:$(COLOR_RESET)     $(words $(OBJECTS)) files"
	@echo "$(COLOR_YELLOW)Target:$(COLOR_RESET)      $(TARGET)"
	@echo "$(COLOR_YELLOW)Install:$(COLOR_RESET)     $(INSTALLDIR)/$(PROJECT_NAME)"
	@echo "$(COLOR_YELLOW)Logs:$(COLOR_RESET)        $(LOGDIR)"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════
# HELP
# ═══════════════════════════════════════════════════════════════════════════

help:
	@echo "$(COLOR_CYAN)╔═══════════════════════════════════════════════════════════╗$(COLOR_RESET)"
	@echo "$(COLOR_CYAN)║  $(EMOJI_SHIELD)  ZAYED CYBERSHIELD - MAKEFILE HELP $(EMOJI_WARRIOR)       ║$(COLOR_RESET)"
	@echo "$(COLOR_CYAN)╚═══════════════════════════════════════════════════════════╝$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_YELLOW)Build Targets:$(COLOR_RESET)"
	@echo "  make              - Build the project (default)"
	@echo "  make debug        - Build with debug symbols"
	@echo "  make release      - Build optimized release"
	@echo ""
	@echo "$(COLOR_YELLOW)Execution:$(COLOR_RESET)"
	@echo "  make run          - Run the application"
	@echo "  make run-sudo     - Run with elevated privileges"
	@echo ""
	@echo "$(COLOR_YELLOW)Testing:$(COLOR_RESET)"
	@echo "  make test         - Run test suite"
	@echo ""
	@echo "$(COLOR_YELLOW)Installation:$(COLOR_RESET)"
	@echo "  make install      - Install system-wide"
	@echo "  make uninstall    - Remove installation"
	@echo "  make setup        - Install dependencies"
	@echo ""
	@echo "$(COLOR_YELLOW)Cleanup:$(COLOR_RESET)"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make clean-logs   - Remove log files"
	@echo "  make clean-all    - Complete cleanup"
	@echo ""
	@echo "$(COLOR_YELLOW)Utilities:$(COLOR_RESET)"
	@echo "  make check-deps   - Check dependencies"
	@echo "  make version      - Show version"
	@echo "  make info         - Show project info"
	@echo "  make help         - Show this help"
	@echo ""
	@echo "$(COLOR_CYAN)$(EMOJI_SHIELD) Built by: $(AUTHOR) $(EMOJI_WARRIOR)$(COLOR_RESET)"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════
# DEPENDENCY GENERATION (for header dependencies)
# ═══════════════════════════════════════════════════════════════════════════

-include $(OBJECTS:.o=.d)

$(OBJDIR)/%.d: $(SRCDIR)/%.c
	@mkdir -p $(OBJDIR)
	@$(CC) $(CPPFLAGS) $(INCLUDES) -MM -MT $(OBJDIR)/$*.o $< > $@

# ═══════════════════════════════════════════════════════════════════════════
# END OF MAKEFILE
# ═══════════════════════════════════════════════════════════════════════════
