#!/usr/bin/env python3
"""Convert Claude Code commands to OpenCode format.

Reads command .md files from commands/ and writes OpenCode-formatted
.md files to .opencode/commands/.
"""

import os
import re
import shutil

# Mapping of source .md files to target OpenCode command paths
COMMAND_MAP = {
    "commands/common-ground/COMMAND.md": ".opencode/commands/common-ground.md",
    "commands/project/discovery/create-epic-discovery.md": ".opencode/commands/discovery/create.md",
    "commands/project/discovery/synthesize-discovery.md": ".opencode/commands/discovery/synthesize.md",
    "commands/project/discovery/approve-synthesis.md": ".opencode/commands/discovery/approve.md",
    "commands/project/planning/create-epic-plan.md": ".opencode/commands/planning/epic-plan.md",
    "commands/project/planning/create-implementation-plan.md": ".opencode/commands/planning/impl-plan.md",
    "commands/project/execution/execute-ticket.md": ".opencode/commands/execution/execute-ticket.md",
    "commands/project/execution/complete-ticket.md": ".opencode/commands/execution/complete-ticket.md",
    "commands/project/retrospectives/complete-epic.md": ".opencode/commands/retrospectives/complete-epic.md",
    "commands/project/retrospectives/complete-sprint.md": ".opencode/commands/retrospectives/complete-sprint.md",
}

# Reference files to copy alongside common-ground command
REFERENCE_COPY = {
    "commands/common-ground/references/": ".opencode/commands/common-ground-references/",
}


def convert_frontmatter(content: str) -> str:
    """Convert Claude Code frontmatter to OpenCode format.

    Claude format:
    ---
    description: ...
    argument-hint: ...
    ---

    OpenCode format:
    ---
    description: ...
    agent: build
    ---
    """
    # Match YAML frontmatter
    match = re.match(r"^---\n(.*?)\n---\n", content, re.DOTALL)
    if not match:
        # No frontmatter, add minimal OpenCode frontmatter
        return f"---\ndescription: Custom command\n---\n\n{content}"

    fm_text = match.group(1)
    body = content[match.end() :]

    # Extract description
    desc_match = re.search(r"^description:\s*(.+)$", fm_text, re.MULTILINE)
    description = desc_match.group(1).strip() if desc_match else "Custom command"

    # Build OpenCode frontmatter
    new_fm = f"---\ndescription: {description}\nagent: build\n---"

    return f"{new_fm}\n{body}"


def replace_claude_paths(content: str) -> str:
    """Replace Claude-specific paths with OpenCode equivalents."""
    replacements = [
        ("~/.claude/common-ground/", "~/.config/opencode/common-ground/"),
        ("~/.claude/skills/", "~/.config/opencode/skills/"),
        ("~/.claude/", "~/.config/opencode/"),
        (".claude/skills/", ".opencode/skills/"),
        (".claude/commands/", ".opencode/commands/"),
        ("CLAUDE.md", "AGENTS.md"),
        # Replace Claude Code command references with OpenCode ones
        ("/common-ground", "/common-ground"),
        ("/create-epic-discovery", "/discovery/create"),
        ("/synthesize-discovery", "/discovery/synthesize"),
        ("/approve-synthesis", "/discovery/approve"),
        ("/create-epic-plan", "/planning/epic-plan"),
        ("/create-implementation-plan", "/planning/impl-plan"),
        ("/execute-ticket", "/execution/execute-ticket"),
        ("/complete-ticket", "/execution/complete-ticket"),
        ("/complete-epic", "/retrospectives/complete-epic"),
        ("/complete-sprint", "/retrospectives/complete-sprint"),
    ]

    for old, new in replacements:
        content = content.replace(old, new)

    return content


def convert_command(src_path: str, dst_path: str) -> None:
    """Convert a single command file."""
    if not os.path.exists(src_path):
        print(f"  SKIP (not found): {src_path}")
        return

    with open(src_path, "r") as f:
        content = f.read()

    # Convert frontmatter
    content = convert_frontmatter(content)

    # Replace Claude-specific paths
    content = replace_claude_paths(content)

    # Ensure target directory exists
    os.makedirs(os.path.dirname(dst_path), exist_ok=True)

    with open(dst_path, "w") as f:
        f.write(content)

    print(f"  OK: {src_path} -> {dst_path}")


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    print("Converting commands to OpenCode format...")
    print()

    for src, dst in COMMAND_MAP.items():
        convert_command(src, dst)

    # Copy reference files for common-ground
    print()
    print("Copying reference files...")
    for src_dir, dst_dir in REFERENCE_COPY.items():
        if os.path.exists(src_dir):
            os.makedirs(dst_dir, exist_ok=True)
            for fname in os.listdir(src_dir):
                src_file = os.path.join(src_dir, fname)
                dst_file = os.path.join(dst_dir, fname)
                if os.path.isfile(src_file):
                    shutil.copy2(src_file, dst_file)
                    print(f"  COPY: {src_file} -> {dst_file}")

    print()
    print("Done! Commands converted to .opencode/commands/")


if __name__ == "__main__":
    main()
