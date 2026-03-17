#!/usr/bin/env python3
"""Update skill frontmatter for OpenCode compatibility.

- Adds `compatibility: opencode` if missing
- Validates name against OpenCode regex: ^[a-z0-9]+(-[a-z0-9]+)*$
- Reports any issues
"""

import os
import re
import sys

SKILLS_DIR = "skills"
NAME_REGEX = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")


def parse_frontmatter(content: str):
    """Parse YAML frontmatter from markdown content."""
    match = re.match(r"^---\n(.*?)\n---\n", content, re.DOTALL)
    if not match:
        return None, content
    return match.group(1), content[match.end() :]


def update_skill(skill_dir: str, skill_name: str, dry_run: bool = False) -> list:
    """Update a single skill's SKILL.md for OpenCode compliance."""
    issues = []
    skill_md = os.path.join(skill_dir, "SKILL.md")

    if not os.path.exists(skill_md):
        issues.append(f"  ERROR: {skill_name} - no SKILL.md found")
        return issues

    with open(skill_md, "r") as f:
        content = f.read()

    fm_text, body = parse_frontmatter(content)
    if fm_text is None:
        issues.append(f"  ERROR: {skill_name} - no YAML frontmatter")
        return issues

    # Validate name
    name_match = re.search(r"^name:\s*(.+)$", fm_text, re.MULTILINE)
    if name_match:
        name = name_match.group(1).strip()
        if not NAME_REGEX.match(name):
            issues.append(f"  ERROR: {skill_name} - name '{name}' doesn't match OpenCode regex")
        if name != skill_name:
            issues.append(f"  WARN: {skill_name} - name '{name}' doesn't match directory name")
    else:
        issues.append(f"  ERROR: {skill_name} - missing 'name' field")

    # Validate description
    desc_match = re.search(r"^description:\s*(.+?)(?=\n\w|\n---)", fm_text, re.MULTILINE | re.DOTALL)
    if not desc_match:
        issues.append(f"  ERROR: {skill_name} - missing 'description' field")

    # Check for compatibility field
    modified = False
    if "compatibility:" not in fm_text:
        # Add compatibility: opencode after license line
        if "license:" in fm_text:
            fm_text = fm_text.replace("license: MIT", "license: MIT\ncompatibility: opencode")
        else:
            fm_text = fm_text + "\ncompatibility: opencode"
        modified = True
    elif "compatibility: Claude" in fm_text or "compatibility: claude" in fm_text:
        fm_text = re.sub(r"compatibility:\s*[Cc]laude", "compatibility: opencode", fm_text)
        modified = True

    if modified:
        new_content = f"---\n{fm_text}\n---\n{body}"
        if not dry_run:
            with open(skill_md, "w") as f:
                f.write(new_content)
            issues.append(f"  UPDATED: {skill_name} - added compatibility: opencode")
        else:
            issues.append(f"  WOULD UPDATE: {skill_name} - add compatibility: opencode")
    else:
        issues.append(f"  OK: {skill_name}")

    return issues


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    dry_run = "--dry-run" in sys.argv

    if dry_run:
        print("DRY RUN - no files will be modified\n")

    print("Validating and updating skills for OpenCode compatibility...\n")

    skills_path = SKILLS_DIR
    if not os.path.exists(skills_path):
        print(f"ERROR: {skills_path} directory not found")
        sys.exit(1)

    all_issues = []
    errors = 0
    updated = 0
    ok = 0

    for skill_name in sorted(os.listdir(skills_path)):
        skill_dir = os.path.join(skills_path, skill_name)
        if not os.path.isdir(skill_dir):
            continue

        issues = update_skill(skill_dir, skill_name, dry_run)
        all_issues.extend(issues)

        for issue in issues:
            if "ERROR" in issue:
                errors += 1
            elif "UPDATED" in issue or "WOULD UPDATE" in issue:
                updated += 1
            elif "OK" in issue:
                ok += 1

    for issue in all_issues:
        print(issue)

    print(f"\nSummary: {ok} ok, {updated} updated, {errors} errors")

    if errors > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
