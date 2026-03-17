#!/usr/bin/env python3
"""Fix bidirectional cross-references in skill metadata.

For each skill A that references skill B in related-skills,
ensures that B also references A. Also fills in empty related-skills
for orphan skills by finding who references them.
"""

import os
import re
import sys

SKILLS_DIR = "skills"


def parse_frontmatter(content: str):
    """Extract YAML frontmatter and body."""
    match = re.match(r"^---\n(.*?)\n---\n", content, re.DOTALL)
    if not match:
        return None, content
    return match.group(1), content[match.end() :]


def get_related_skills(fm_text: str) -> list[str]:
    """Extract related-skills list from frontmatter text."""
    match = re.search(r"related-skills:\s*(.+)", fm_text)
    if not match:
        return []
    value = match.group(1).strip()
    if not value:
        return []
    return [s.strip() for s in value.split(",") if s.strip()]


def set_related_skills(fm_text: str, skills: list[str]) -> str:
    """Set related-skills in frontmatter text."""
    new_value = ", ".join(sorted(set(skills)))
    if re.search(r"related-skills:", fm_text):
        return re.sub(r"related-skills:.*", f"related-skills: {new_value}", fm_text)
    else:
        # Add after the last metadata line
        return fm_text + f"\n  related-skills: {new_value}"


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root)

    dry_run = "--dry-run" in sys.argv

    # Phase 1: Build reference graph
    print("Phase 1: Building reference graph...")
    refs: dict[str, list[str]] = {}  # skill -> [referenced skills]
    all_skills = set()

    for skill_name in sorted(os.listdir(SKILLS_DIR)):
        skill_dir = os.path.join(SKILLS_DIR, skill_name)
        skill_md = os.path.join(skill_dir, "SKILL.md")
        if not os.path.isdir(skill_dir) or not os.path.exists(skill_md):
            continue

        all_skills.add(skill_name)

        with open(skill_md, "r") as f:
            content = f.read()

        fm_text, _ = parse_frontmatter(content)
        if fm_text is None:
            continue

        related = get_related_skills(fm_text)
        refs[skill_name] = related

    # Phase 2: Compute missing back-references
    print("Phase 2: Computing missing back-references...")
    additions: dict[str, set[str]] = {s: set() for s in all_skills}

    for skill_a, related in refs.items():
        for skill_b in related:
            if skill_b in all_skills and skill_a not in refs.get(skill_b, []):
                additions[skill_b].add(skill_a)

    total_additions = sum(len(v) for v in additions.values())
    print(f"  Found {total_additions} missing back-references across {sum(1 for v in additions.values() if v)} skills")

    # Phase 3: Apply fixes
    print(f"\nPhase 3: {'DRY RUN - ' if dry_run else ''}Applying fixes...")
    fixed = 0

    for skill_name in sorted(all_skills):
        if not additions[skill_name]:
            continue

        skill_md = os.path.join(SKILLS_DIR, skill_name, "SKILL.md")
        with open(skill_md, "r") as f:
            content = f.read()

        fm_text, body = parse_frontmatter(content)
        if fm_text is None:
            continue

        current = get_related_skills(fm_text)
        new_refs = sorted(set(current) | additions[skill_name])

        if set(new_refs) == set(current):
            continue

        added = additions[skill_name] - set(current)
        print(f"  {skill_name}: +{len(added)} refs ({', '.join(sorted(added))})")

        if not dry_run:
            fm_text = set_related_skills(fm_text, new_refs)
            new_content = f"---\n{fm_text}\n---\n{body}"
            with open(skill_md, "w") as f:
                f.write(new_content)

        fixed += 1

    print(f"\n{'Would fix' if dry_run else 'Fixed'} {fixed} skills with {total_additions} new back-references")


if __name__ == "__main__":
    main()
