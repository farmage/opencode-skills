# Upstream Sync Guide

How to pull new skills and fixes from the original [Claude Skills](https://github.com/Jeffallan/claude-skills) repo into this OpenCode fork.

## Setup (once)

```bash
git remote add upstream https://github.com/Jeffallan/claude-skills.git
```

## Check for updates

```bash
git fetch upstream
git log upstream/v0.4.10..upstream/main --oneline
```

If empty — nothing new. If commits appear — proceed with sync.

## Sync procedure

### 1. Create a working branch

```bash
git checkout -b sync/upstream-vX.Y.Z
```

### 2. Merge upstream changes

```bash
git merge upstream/main
```

Resolve conflicts if any. Typical conflict areas:
- `CLAUDE.md` (deleted in our fork, may be modified upstream) — keep deleted, ours is `AGENTS.md`
- `skills/*/SKILL.md` frontmatter — keep `compatibility: opencode`, accept content changes
- `.claude-plugin/` — keep deleted, ours is `opencode.json`
- `README.md`, `Makefile` — keep ours, cherry-pick content if needed

### 3. Re-apply OpenCode transformations

```bash
# Activate venv
source .venv/bin/activate

# Update frontmatter on any new/changed skills
python3 scripts/update-skills-opencode.py

# Fix bidirectional cross-references
python3 scripts/fix-crossrefs.py

# Convert any new commands to OpenCode format
python3 scripts/convert-commands.py

# Update doc counts
python3 scripts/update-docs.py

# Validate everything
make validate
```

### 4. Install new skills locally and test

```bash
# Copy to temp project and test with OpenCode
mkdir -p /tmp/sync-test && cd /tmp/sync-test && git init
cp -r /path/to/opencode-skills/skills/* .opencode/skills/
opencode run --model openai/gpt-4o-mini "List all available skills"
```

### 5. Commit and tag

```bash
git add -A
git commit -m "sync: merge upstream vX.Y.Z

Merged from https://github.com/Jeffallan/claude-skills
Re-applied OpenCode transformations (frontmatter, crossrefs, commands)"

# Tag the new sync point
git tag -a upstream/vX.Y.Z HEAD -m "Sync point with upstream Jeffallan/claude-skills vX.Y.Z"
```

### 6. Push

```bash
git push origin sync/upstream-vX.Y.Z
git push origin upstream/vX.Y.Z

# After review, merge to main
git checkout main
git merge sync/upstream-vX.Y.Z
git push origin main
```

## Conflict resolution cheatsheet

| File/pattern | Resolution |
|---|---|
| `CLAUDE.md` | Keep deleted (we use `AGENTS.md`) |
| `MODELCLAUDE.md` | Keep deleted (we use `MODELAGENTS.md`) |
| `.claude-plugin/*` | Keep deleted (we use `opencode.json`) |
| `.claude/*` | Keep deleted (we use `.opencode/`) |
| `.serena/*` | Keep deleted |
| `skills/*/SKILL.md` | Accept upstream content, then re-run `update-skills-opencode.py` |
| `commands/*.yaml` | Accept upstream, then re-run `convert-commands.py` |
| `commands/*.md` | Accept upstream, then re-run `convert-commands.py` |
| `README.md` | Keep ours, manually review for new content worth porting |
| `Makefile` | Keep ours |
| `scripts/*` | Merge carefully, keep our OpenCode-specific scripts |

## Sync tags

All sync points are tagged as `upstream/vX.Y.Z`:

```bash
git tag -l 'upstream/*'
```

To see what changed between two syncs:

```bash
git log upstream/v0.4.10..upstream/v0.5.0 --oneline
```
