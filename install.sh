#!/usr/bin/env bash
set -euo pipefail

# ─── OpenCode Skills Installer ────────────────────────────────────────────────
#
# Install 66 specialized skills + 10 workflow commands for OpenCode.
#
# Usage:
#   Local (from cloned repo):
#     ./install.sh
#
#   Remote (one-liner):
#     curl -fsSL https://raw.githubusercontent.com/farmage/opencode-skills/main/install.sh | bash
#
#   Options:
#     --local     Install into .opencode/ (project-local) instead of global
#     --uninstall Remove previously installed skills
#     --help      Show this help
# ──────────────────────────────────────────────────────────────────────────────

REPO_URL="https://github.com/farmage/opencode-skills.git"
REPO_BRANCH="main"

# Colors (if terminal supports them)
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN='' YELLOW='' RED='' BOLD='' RESET=''
fi

info()  { echo -e "${GREEN}>${RESET} $*"; }
warn()  { echo -e "${YELLOW}!${RESET} $*"; }
error() { echo -e "${RED}x${RESET} $*" >&2; }
header() { echo -e "\n${BOLD}$*${RESET}"; }

# ─── Parse args ───────────────────────────────────────────────────────────────

LOCAL_INSTALL=false
UNINSTALL=false

for arg in "$@"; do
  case "$arg" in
    --local)     LOCAL_INSTALL=true ;;
    --uninstall) UNINSTALL=true ;;
    --help|-h)
      echo "OpenCode Skills Installer"
      echo ""
      echo "Usage:"
      echo "  ./install.sh              Install globally (~/.config/opencode/)"
      echo "  ./install.sh --local      Install into current project (.opencode/)"
      echo "  ./install.sh --uninstall  Remove installed skills"
      echo "  curl -fsSL https://raw.githubusercontent.com/farmage/opencode-skills/main/install.sh | bash"
      echo ""
      exit 0
      ;;
    *)
      error "Unknown option: $arg"
      exit 1
      ;;
  esac
done

# ─── Determine paths ─────────────────────────────────────────────────────────

DEST="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

if [ "$LOCAL_INSTALL" = true ]; then
  DEST=".opencode"
fi

SKILLS_DEST="$DEST/skills"
COMMANDS_DEST="$DEST/commands"

# ─── Detect source ────────────────────────────────────────────────────────────
# If running from a cloned repo, use local files.
# If piped via curl, clone to temp directory.

CLEANUP_TMPDIR=""

find_source_dir() {
  # Check if we're inside the repo already
  if [ -d "skills" ] && [ -f "version.json" ] && [ -d ".opencode/commands" ]; then
    SOURCE_DIR="."
    return
  fi

  # Check parent (in case install.sh is run from a subdirectory)
  if [ -d "../skills" ] && [ -f "../version.json" ]; then
    SOURCE_DIR=".."
    return
  fi

  # Not in repo — need to clone
  header "Cloning opencode-skills..."
  TMPDIR=$(mktemp -d)
  CLEANUP_TMPDIR="$TMPDIR"
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$TMPDIR" 2>&1 | tail -1
  SOURCE_DIR="$TMPDIR"
}

cleanup() {
  if [ -n "$CLEANUP_TMPDIR" ] && [ -d "$CLEANUP_TMPDIR" ]; then
    rm -rf "$CLEANUP_TMPDIR"
  fi
}
trap cleanup EXIT

# ─── Uninstall ────────────────────────────────────────────────────────────────

if [ "$UNINSTALL" = true ]; then
  header "Uninstalling OpenCode Skills from $DEST"

  find_source_dir

  removed=0
  for skill_dir in "$SOURCE_DIR"/skills/*/; do
    name=$(basename "$skill_dir")
    target="$SKILLS_DEST/$name"
    if [ -d "$target" ] || [ -L "$target" ]; then
      rm -rf "$target"
      removed=$((removed + 1))
    fi
  done

  info "Removed $removed skill(s) from $SKILLS_DEST"
  info "Restart OpenCode to apply changes."
  exit 0
fi

# ─── Install ──────────────────────────────────────────────────────────────────

find_source_dir

VERSION=$(python3 -c "import json; print(json.load(open('$SOURCE_DIR/version.json'))['version'])" 2>/dev/null || echo "unknown")

header "OpenCode Skills v$VERSION"
echo ""
info "Source:      $SOURCE_DIR"
info "Destination: $DEST"
echo ""

# Count what we're installing
skill_count=$(ls -d "$SOURCE_DIR"/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
cmd_count=$(find "$SOURCE_DIR/.opencode/commands" -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')

# Create destination directories
mkdir -p "$SKILLS_DEST" "$COMMANDS_DEST"

# Copy skills
header "Installing $skill_count skills..."
cp -r "$SOURCE_DIR"/skills/* "$SKILLS_DEST/"
info "Skills installed to $SKILLS_DEST/"

# Copy commands (skip if source and dest are the same directory)
header "Installing $cmd_count commands..."
src_commands_real=$(cd "$SOURCE_DIR/.opencode/commands" && pwd)
dst_commands_real=$(mkdir -p "$COMMANDS_DEST" && cd "$COMMANDS_DEST" && pwd)

if [ "$src_commands_real" = "$dst_commands_real" ]; then
  info "Commands already in place (same directory)."
else
  cp -r "$SOURCE_DIR"/.opencode/commands/* "$COMMANDS_DEST/"
  info "Commands installed to $COMMANDS_DEST/"
fi

# Summary
echo ""
header "Installation complete!"
echo ""
info "Skills:   $skill_count"
info "Commands: $cmd_count"
echo ""

if [ "$LOCAL_INSTALL" = true ]; then
  info "Installed to .opencode/ (project-local)"
  warn "Add .opencode/skills/ to .gitignore if you don't want to commit them."
else
  info "Installed to $DEST (global)"
fi

echo ""
info "Restart OpenCode to activate."
echo ""

# Show available commands
echo "Available workflow commands:"
echo "  /common-ground                    Surface project assumptions"
echo "  /discovery/create <epic-key>      Create discovery document"
echo "  /discovery/synthesize <urls...>   Synthesize findings"
echo "  /discovery/approve <url>          Approve and create tickets"
echo "  /planning/epic-plan <epic-key>    Create planning document"
echo "  /planning/impl-plan <doc-url>     Generate implementation plan"
echo "  /execution/execute-ticket <key>   Execute a ticket"
echo "  /execution/complete-ticket <key>  Complete a ticket"
echo "  /retrospectives/complete-epic     Complete an epic"
echo "  /retrospectives/complete-sprint   Sprint retrospective"
