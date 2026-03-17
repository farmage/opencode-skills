.PHONY: install install-local dev-link dev-unlink validate check test \
       site-dev site-build lint format lint-fix help

SKILLS_SRC   := skills
COMMANDS_SRC := .opencode/commands
VERSION      := $(shell python3 -c "import json; print(json.load(open('version.json'))['version'])")
DEST         := $(or $(XDG_CONFIG_HOME),$(HOME)/.config)/opencode

# ─── Installation ─────────────────────────────────────────────────────────────

## Install skills and commands globally (~/.config/opencode/)
install:
	@mkdir -p "$(DEST)/skills" "$(DEST)/commands"
	@cp -r $(SKILLS_SRC)/* "$(DEST)/skills/"
	@cp -r $(COMMANDS_SRC)/* "$(DEST)/commands/"
	@echo ""
	@echo "Installed to $(DEST):"
	@echo "  Skills:   $$(ls -d $(SKILLS_SRC)/*/ 2>/dev/null | wc -l | tr -d ' ') skills"
	@echo "  Commands: $$(find $(COMMANDS_SRC) -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ') commands"
	@echo ""
	@echo "Restart OpenCode to activate."

## Install skills and commands into current project (.opencode/)
install-local:
	@mkdir -p .opencode/skills .opencode/commands
	@cp -r $(SKILLS_SRC)/* .opencode/skills/
	@cp -r $(COMMANDS_SRC)/* .opencode/commands/
	@echo ""
	@echo "Installed to .opencode/:"
	@echo "  Skills:   $$(ls -d $(SKILLS_SRC)/*/ 2>/dev/null | wc -l | tr -d ' ') skills"
	@echo "  Commands: $$(find $(COMMANDS_SRC) -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ') commands"
	@echo ""
	@echo "Restart OpenCode to activate."

## Uninstall globally-installed skills and commands
uninstall:
	@echo "Removing skills from $(DEST)/skills/ ..."
	@for skill in $(SKILLS_SRC)/*/; do \
		name=$$(basename "$$skill"); \
		if [ -d "$(DEST)/skills/$$name" ]; then \
			rm -rf "$(DEST)/skills/$$name"; \
		fi; \
	done
	@echo "Removing commands from $(DEST)/commands/ ..."
	@for cmd in $$(find $(COMMANDS_SRC) -name '*.md' -type f); do \
		rel=$${cmd#$(COMMANDS_SRC)/}; \
		if [ -f "$(DEST)/commands/$$rel" ]; then \
			rm -f "$(DEST)/commands/$$rel"; \
		fi; \
	done
	@echo "Done. Restart OpenCode."

# ─── Development ──────────────────────────────────────────────────────────────

## Symlink skills for live development (edits take effect on restart)
dev-link:
	@mkdir -p "$(DEST)/skills"
	@linked=0; \
	for skill in $(SKILLS_SRC)/*/; do \
		name=$$(basename "$$skill"); \
		target="$(DEST)/skills/$$name"; \
		src="$$(cd "$$skill" && pwd)"; \
		if [ -L "$$target" ]; then \
			echo "  SKIP (already linked): $$name"; \
		elif [ -d "$$target" ]; then \
			mv "$$target" "$$target.bak"; \
			ln -s "$$src" "$$target"; \
			echo "  LINK: $$name (backed up existing)"; \
			linked=$$((linked + 1)); \
		else \
			ln -s "$$src" "$$target"; \
			echo "  LINK: $$name"; \
			linked=$$((linked + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "Linked $$linked skill(s) to $(DEST)/skills/"; \
	echo "Restart OpenCode to load changes from working copy."

## Remove dev symlinks and restore backed-up originals
dev-unlink:
	@unlinked=0; \
	for skill in $(SKILLS_SRC)/*/; do \
		name=$$(basename "$$skill"); \
		target="$(DEST)/skills/$$name"; \
		if [ -L "$$target" ]; then \
			rm "$$target"; \
			if [ -d "$$target.bak" ]; then \
				mv "$$target.bak" "$$target"; \
				echo "  RESTORED: $$name"; \
			else \
				echo "  REMOVED: $$name (no backup)"; \
			fi; \
			unlinked=$$((unlinked + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "Unlinked $$unlinked skill(s)."; \
	echo "Restart OpenCode to load released versions."

# ─── Validation ───────────────────────────────────────────────────────────────

## Validate skills (YAML, names, references)
validate:
	python3 scripts/validate-skills.py

## Validate markdown syntax
validate-md:
	python3 scripts/validate-markdown.py

## Full validation (skills + markdown + doc sync)
check: validate validate-md
	python3 scripts/update-docs.py --check

# ─── Documentation site ──────────────────────────────────────────────────────

site-dev:
	cd site && npm run dev

site-build:
	cd site && npm run build

# ─── Linting ──────────────────────────────────────────────────────────────────

lint:
	ruff check scripts/
	ruff format --check scripts/

format:
	ruff check --fix scripts/
	ruff format scripts/

lint-fix: format

# ─── Test ─────────────────────────────────────────────────────────────────────

test:
	bash scripts/test-makefile.sh

# ─── Info ─────────────────────────────────────────────────────────────────────

## Show version and counts
info:
	@echo "OpenCode Skills v$(VERSION)"
	@echo "  Skills:     $$(ls -d $(SKILLS_SRC)/*/ 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  Commands:   $$(find $(COMMANDS_SRC) -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  References: $$(find $(SKILLS_SRC) -path '*/references/*.md' -type f 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  Dest:       $(DEST)"

## Show available targets
help:
	@echo "OpenCode Skills v$(VERSION)"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Installation:"
	@echo "  install        Copy skills + commands to ~/.config/opencode/"
	@echo "  install-local  Copy skills + commands to .opencode/ (project-local)"
	@echo "  uninstall      Remove globally-installed skills and commands"
	@echo ""
	@echo "Development:"
	@echo "  dev-link       Symlink skills for live editing"
	@echo "  dev-unlink     Remove symlinks, restore originals"
	@echo ""
	@echo "Validation:"
	@echo "  validate       Validate skill YAML and structure"
	@echo "  validate-md    Validate markdown syntax"
	@echo "  check          Full validation (skills + markdown + docs)"
	@echo ""
	@echo "Other:"
	@echo "  info           Show version and counts"
	@echo "  lint / format  Check / fix Python code style"
	@echo "  test           Run test suite"
	@echo "  site-dev       Start docs site (dev)"
	@echo "  site-build     Build docs site"
