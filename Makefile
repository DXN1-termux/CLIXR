.PHONY: help install uninstall update list check test count fmt clean

SHELL := /bin/bash
ROOT  := $(shell pwd)

help:            ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install:         ## Run the installer
	@bash install.sh

uninstall:       ## Remove the clixr symlink
	@bash uninstall.sh

update:          ## Self-update from git
	@bash update.sh

list:            ## List all tools
	@bash bin/clixr list

count:           ## Count plugins
	@printf "plugins: " && find plugins -type f | wc -l | xargs

check:           ## Syntax-check every script
	@err=0; for f in bin/clixr *.sh lib/*.sh plugins/*/*; do \
	  bash -n "$$f" || { echo "FAIL $$f"; err=1; }; done; \
	  [ $$err -eq 0 ] && echo "all scripts OK"

test: check      ## Alias for check

fmt:             ## Make every plugin & script executable
	@chmod +x bin/clixr *.sh plugins/*/* 2>/dev/null; echo "permissions fixed"

clean:           ## Remove generated/temp files
	@rm -f /tmp/clixr_* 2>/dev/null; echo "cleaned"
