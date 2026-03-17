# OpenCode Skills

> OpenCode adaptation of [Claude Skills](https://github.com/Jeffallan/claude-skills) by [jeffallan](https://github.com/Jeffallan) (MIT License).
> Converted to work natively with [OpenCode](https://opencode.ai) skill and command system.

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge" alt="License"/></a>
  <a href="https://opencode.ai"><img src="https://img.shields.io/badge/OpenCode-Skills-purple.svg?style=for-the-badge" alt="OpenCode"/></a>
</p>

---

## Quick Start

**Recommended** -- clone and run the installer:

```bash
git clone https://github.com/farmage/opencode-skills.git
cd opencode-skills
./install.sh
```

**Alternative -- via Makefile:**

```bash
make install          # global (~/.config/opencode/)
make install-local    # project-local (.opencode/)
```

**Remote one-liner** (no clone needed):

```bash
curl -fsSL https://raw.githubusercontent.com/farmage/opencode-skills/main/install.sh | bash
```

Restart OpenCode after installation. See [Quick Start Guide](QUICKSTART.md) for details.

---

## What's Included

| | Count | Description |
|-|------:|-------------|
| Skills | <!-- SKILL_COUNT -->66<!-- /SKILL_COUNT --> | Specialized agents across 12 domains |
| Workflows | <!-- WORKFLOW_COUNT -->9<!-- /WORKFLOW_COUNT --> | Project commands (discovery, planning, execution, retrospectives) |
| References | <!-- REFERENCE_COUNT -->365<!-- /REFERENCE_COUNT --> | Deep-dive technical documents loaded on demand |

### Skill categories

Languages (12) -- Python, TypeScript, JavaScript, Go, Rust, C++, C#, Java, PHP, Swift, Kotlin, SQL

Frameworks (14) -- React, Next.js, Vue, Angular, NestJS, Django, FastAPI, Spring Boot, Laravel, Rails, .NET Core, React Native, Flutter, WordPress

Infrastructure & DevOps (8) -- Kubernetes, Terraform, Docker/CI, Cloud Architecture, SRE, Monitoring, Chaos Engineering, Embedded Systems

Architecture & Quality (8) -- API Design, GraphQL, Microservices, Security Review, Code Review, Testing, Debugging, Documentation

Specialized (6) -- Salesforce, Shopify, MCP Development, Prompt Engineering, RAG, Fine-tuning

See [Skills Guide](SKILLS_GUIDE.md) for the full list with decision trees.

---

## How It Works

OpenCode discovers skills in two locations:

```
~/.config/opencode/skills/<name>/SKILL.md    # global
.opencode/skills/<name>/SKILL.md             # project-local
```

When you send a message, OpenCode matches it against skill descriptions and loads the relevant `SKILL.md` via the built-in `skill` tool. Each skill has a `references/` directory with detailed technical docs that load on demand -- keeping context small until needed.

```
Your prompt
  --> OpenCode matches skill by description/triggers
    --> Loads SKILL.md (~100 lines: workflow, constraints, patterns)
      --> Loads references/*.md on demand (100-600 lines each)
```

---

## Usage

Skills activate automatically based on context:

```
"Implement JWT authentication in my NestJS API"
  --> nestjs-expert + secure-code-guardian

"Debug this memory leak in my Node.js app"
  --> debugging-wizard + relevant framework expert

"Review this PR for security issues"
  --> security-reviewer + code-reviewer
```

Multi-skill workflows for complex tasks:

```
Feature:   Feature Forge -> Architecture Designer -> Fullstack Guardian -> Test Master
Debugging: Debugging Wizard -> Framework Expert -> Test Master -> Code Reviewer
Security:  Secure Code Guardian -> Security Reviewer -> Test Master
```

---

## Workflow Commands

Project management commands integrating with Jira and Confluence via [Atlassian MCP](docs/ATLASSIAN_MCP_SETUP.md):

| Command | Description |
|---------|-------------|
| `/common-ground` | Surface and validate project assumptions |
| `/discovery/create` | Create discovery document for an epic |
| `/discovery/synthesize` | Synthesize research findings |
| `/discovery/approve` | Approve synthesis and create tickets |
| `/planning/epic-plan` | Generate epic planning document |
| `/planning/impl-plan` | Create implementation plan from overview |
| `/execution/execute-ticket` | Execute a Jira ticket following its plan |
| `/execution/complete-ticket` | Finalize ticket, transition Jira, update docs |
| `/retrospectives/complete-epic` | Epic completion report and closeout |
| `/retrospectives/complete-sprint` | Sprint retrospective analysis |

---

## Project Structure

```
opencode-skills/
  skills/                    # 66 skill directories (SKILL.md + references/)
  .opencode/
    commands/                # 10 workflow commands (OpenCode format)
      common-ground.md
      discovery/
      planning/
      execution/
      retrospectives/
  opencode.json              # OpenCode project config
  AGENTS.md                  # Project rules and conventions
  install.sh                 # Installer (local + curl-compatible)
  Makefile                   # install, dev-link, validate, etc.
  SKILLS_GUIDE.md            # Full skill reference with decision trees
```

---

## Development

```bash
make dev-link       # Symlink skills to ~/.config/opencode/skills/ for live editing
make dev-unlink     # Remove symlinks, restore originals
make validate       # Validate skill YAML, names, cross-references
make info           # Show version and counts
make help           # All available targets
```

Requires Python 3 and PyYAML (`pip install -r requirements.txt`).

---

## Documentation

- [Quick Start Guide](QUICKSTART.md) -- Installation and first steps
- [Skills Guide](SKILLS_GUIDE.md) -- Full skill list, decision trees, combinations
- [Common Ground](docs/COMMON_GROUND.md) -- Context engineering guide
- [Workflow Commands](docs/WORKFLOW_COMMANDS.md) -- Workflow reference and lifecycle
- [Atlassian MCP Setup](docs/ATLASSIAN_MCP_SETUP.md) -- Jira/Confluence integration
- [Local Development](docs/local_skill_development.md) -- Skill development workflow

---

## License & Attribution

MIT License. See [LICENSE](LICENSE).

Based on [Claude Skills](https://github.com/Jeffallan/claude-skills) by [jeffallan](https://github.com/Jeffallan) -- original skill content, reference files, and workflow commands. OpenCode adaptation: directory structure, command format, frontmatter, installer, and validation tooling.
