# OpenCode Skills Project Configuration

> This file governs OpenCode's behavior when working on the opencode-skills repository.

---

## Skill Authorship Standards

Skills follow the [Agent Skills specification](https://agentskills.io/specification). This section covers project-specific conventions that go beyond the base spec.

### The Description Trap

**Critical:** Never put process steps or workflow sequences in descriptions. When descriptions contain step-by-step instructions, agents follow the brief description instead of reading the full skill content. This defeats the purpose of detailed skills.

Brief capability statements (what it does) and trigger conditions (when to use it) are both appropriate. Process steps (how it works) are not.

**BAD - Process steps in description:**
```yaml
description: Use for debugging. First investigate root cause, then analyze
patterns, test hypotheses, and implement fixes with tests.
```

**GOOD - Capability + trigger:**
```yaml
description: Diagnoses bugs through root cause analysis and pattern matching.
Use when encountering errors or unexpected behavior requiring investigation.
```

**Format:** `[Brief capability statement]. Use when [triggering conditions].`

Descriptions tell WHAT the skill does and WHEN to use it. The SKILL.md body tells HOW.

---

### Frontmatter Requirements

Per the [Agent Skills specification](https://agentskills.io/specification) and [OpenCode Agent Skills docs](https://opencode.ai/docs/skills/), the following fields are recognized:

```yaml
---
name: skill-name-with-hyphens
description: [Brief capability statement]. Use when [triggering conditions] - max 1024 chars
license: MIT
compatibility: opencode
metadata:
  author: https://github.com/Jeffallan
  version: "1.0.0"
  domain: frontend
  triggers: keyword1, keyword2, keyword3
  role: specialist
  scope: implementation
  output-format: code
  related-skills: fullstack-guardian, test-master, devops-engineer
---
```

**Top-level fields (recognized by OpenCode):**
- `name`: 1-64 chars, lowercase alphanumeric with single hyphen separators (`^[a-z0-9]+(-[a-z0-9]+)*$`). Must match the directory name.
- `description`: 1-1024 characters. Capability statement + trigger conditions. No process steps.
- `license`: Always `MIT` for this project
- `compatibility`: Set to `opencode` for OpenCode-native skills
- `metadata`: String-to-string map for custom fields (project-specific)

**Metadata fields (project-specific):**
- `author`: GitHub profile URL of the skill author
- `version`: Semantic version string (quoted, e.g., `"1.0.0"`)
- `domain`: Category from the domain list below
- `triggers`: Comma-separated searchable keywords
- `role`: `specialist` | `expert` | `architect` | `engineer`
- `scope`: `implementation` | `review` | `design` | `system-design` | `testing` | `analysis` | `infrastructure` | `optimization` | `architecture`
- `output-format`: `code` | `document` | `report` | `architecture` | `specification` | `schema` | `manifests` | `analysis` | `analysis-and-code` | `code+analysis`
- `related-skills`: Comma-separated skill directory names (e.g., `fullstack-guardian, test-master`). Must resolve to existing skill directories.

**Domain values:**
`language` · `backend` · `frontend` · `infrastructure` · `api-architecture` · `quality` · `devops` · `security` · `data-ml` · `platform` · `specialized` · `workflow`

---

### Reference File Standards

Reference files follow the [Agent Skills specification](https://agentskills.io/specification). No specific headers are required.

**Guidelines:**
- 100-600 lines per reference file
- Keep files focused on a single topic
- Complete, working code examples with TypeScript types
- Cross-reference related skills where relevant
- Include "when to use" and "when not to use" guidance
- Practical patterns over theoretical explanations

### Framework Idiom Principle

Reference files for framework-specific skills must reflect the idiomatic best practices of that framework, not generic patterns applied uniformly across all skills. If a framework provides a built-in mechanism (e.g., global error handling, middleware, dependency injection), reference examples should use it rather than duplicating that behavior manually. Each framework's conventions for error handling, architecture, and code organization take precedence over cross-project consistency.

---

### Progressive Disclosure Architecture

**Tier 1 - SKILL.md (~80-100 lines)**
- Role definition and expertise level
- When-to-use guidance (triggers)
- Core workflow (5 steps)
- Constraints (MUST DO / MUST NOT DO)
- Routing table to references

**Tier 2 - Reference Files (100-600 lines each)**
- Deep technical content
- Complete code examples
- Edge cases and anti-patterns
- Loaded only when context requires

**Goal:** 50% token reduction through selective loading.

---

## Installation

### For OpenCode Users

```bash
# Copy skills to OpenCode global skills directory
cp -r ./skills/* ~/.config/opencode/skills/

# Copy commands to OpenCode global commands directory
cp -r ./.opencode/commands/* ~/.config/opencode/commands/
```

Restart OpenCode after copying.

### For Project-Local Use

```bash
# Copy skills into your project
cp -r ./skills/* .opencode/skills/

# Copy commands into your project
cp -r ./.opencode/commands/* .opencode/commands/
```

---

## Project Workflow

### When Creating New Skills

1. Check existing skills for overlap
2. Write SKILL.md with capability + trigger description (no process steps)
3. Create reference files for deep content (100+ lines)
4. Add routing table linking topics to references
5. Test skill triggers with realistic prompts
6. Update SKILLS_GUIDE.md if adding new domain

### When Modifying Skills

1. Read the full current skill before editing
2. Maintain capability + trigger description format (no process steps)
3. Preserve progressive disclosure structure
4. Update related cross-references
5. Verify routing table accuracy

---

## Release Checklist

When releasing a new version, follow these steps.

### 1. Update Version and Counts

Version and counts are managed through `version.json`:

```json
{
  "version": "0.5.0",
  "skillCount": 66,
  "workflowCount": 9,
  "referenceFileCount": 365
}
```

**To release a new version:**

1. Update the `version` field in `version.json`
2. Run the update script:

```bash
python scripts/update-docs.py
```

### 2. Update CHANGELOG.md

Add new version entry at the top following Keep a Changelog format.

### 3. Validate Skills Integrity

```bash
python scripts/validate-skills.py
```

### 4. Validate Markdown Syntax

```bash
python scripts/validate-markdown.py
```

---

## Attribution

Behavioral patterns and process discipline adapted from:
- **[obra/superpowers](https://github.com/obra/superpowers)** by Jesse Vincent (@obra)
- License: MIT

Original skills by **[jeffallan/claude-skills](https://github.com/jeffallan/claude-skills)** - MIT License.

Research documented in: `research/superpowers.md`
