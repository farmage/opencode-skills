# Quick Start Guide

Get up and running with the OpenCode Skills pack.

## Installation (Choose One)

### Global Install (Recommended)
```bash
# Clone the repo
git clone https://github.com/farmage/opencode-skills.git
cd opencode-skills

# Copy skills to OpenCode global skills directory
cp -r ./skills/* ~/.config/opencode/skills/

# Copy commands to OpenCode global commands directory
cp -r ./.opencode/commands/* ~/.config/opencode/commands/

# Restart OpenCode when done
```

### Project-Local Install
```bash
# Copy skills into your project
cp -r ./skills/* .opencode/skills/

# Copy commands into your project
cp -r ./.opencode/commands/* .opencode/commands/
```

### Install via Agent Skills CLI
```bash
npx agent-skills-cli@latest add @Jeffallan/claude-skills
```

> **Note:** This method installs skills only. Slash commands (`/common-ground`, `/discovery/*`) are not included. Installs to 42+ AI agents including OpenCode, Claude, Cursor, Copilot, Windsurf, and more. [Learn more](https://www.agentskills.in)

## Test Your Installation

Verify skills are working:

```bash
# Test NestJS Expert
"Help me implement JWT authentication in NestJS"

# Test React Expert
"Create a custom React hook for form validation"

# Test Debugging Wizard
"Debug this memory leak in my Node.js application"

# Test Security Reviewer
"Review this code for security vulnerabilities"
```

## First Steps

### 1. What's Included

<!-- SKILL_COUNT -->66<!-- /SKILL_COUNT --> skills covering:
- 12 Language Experts (Python, TypeScript, Go, Rust, C++, Swift, Kotlin, C#, PHP, Java, SQL, JavaScript)
- 7 Backend Framework Experts (NestJS, Django, FastAPI, Spring Boot, Laravel, Rails, .NET Core)
- 7 Frontend & Mobile Experts (React, Next.js, Vue, Angular, React Native, Flutter)
- <!-- WORKFLOW_COUNT -->9<!-- /WORKFLOW_COUNT --> Project Workflow Commands (discovery, planning, execution, retrospectives)
- Plus: Infrastructure, DevOps, Security, Architecture, Testing, and more

### 2. First Prompt

Specify the tech stack and OpenCode activates the appropriate skills:

```
"I need to implement a user profile feature in my NestJS API with authentication"
# Activates NestJS Expert + Secure Code Guardian
```

```
"My React app has a memory leak, help me debug it"
# Activates Debugging Wizard + React Expert
```

### 3. Learn More

See [Skills Guide](SKILLS_GUIDE.md) for decision trees, skill combinations, and detailed examples for every category.

## Effective Usage

### 1. Provide Context
Include relevant information:
- Framework/language you're using
- What you're trying to accomplish
- Any constraints or requirements
- Error messages (if debugging)

### 2. Ask for Multiple Perspectives
```
"Review this authentication code for both security and performance issues"
# Activates: Security Reviewer + Code Reviewer
```

### 3. Reference the Guides
- [README](README.md) - Overview and architecture
- [Skills Guide](SKILLS_GUIDE.md) - Detailed skill reference with decision trees
- [Common Ground](docs/COMMON_GROUND.md) - Context engineering guide
- [Workflow Commands](docs/WORKFLOW_COMMANDS.md) - Workflow commands reference
- [Contributing](CONTRIBUTING.md) - How to customize/extend

## Troubleshooting

### Skills Not Activating
1. Restart OpenCode after installation
2. Check skill files exist: `ls ~/.config/opencode/skills/`
3. Be more specific with framework/technology names
4. Try explicitly mentioning the skill name: "Use the NestJS Expert to help me..."

### Skills Not Loading After Install
1. Verify skills directory structure: each skill needs `<name>/SKILL.md`
2. Check for YAML frontmatter with `name` and `description` fields
3. Ensure skill names match directory names (lowercase, hyphens only)

### How to Update
```bash
cd opencode-skills && git pull
cp -r ./skills/* ~/.config/opencode/skills/
```

### Need Help
- Check [Skills Guide](SKILLS_GUIDE.md) for skill-specific guidance
- Review individual `skills/*/SKILL.md` files
- Open an [issue on GitHub](https://github.com/jeffallan/claude-skills/issues)

## OpenCode Configuration

You can also configure skills permissions in your `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "skill": {
      "*": "allow"
    }
  }
}
```

And reference additional instruction files:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["AGENTS.md", "docs/guidelines.md"]
}
```

See [OpenCode Config docs](https://opencode.ai/docs/config/) for full reference.

## Next Steps

### Explore Skills
Browse the `skills/` directory for available skills.

### Customize
Edit any `SKILL.md` to match team conventions.

### Contribute
Add new skills. See `CONTRIBUTING.md`.

## Support

- Documentation: Check [README](README.md) and [Skills Guide](SKILLS_GUIDE.md)
- Issues: [GitHub Issues](https://github.com/jeffallan/claude-skills/issues)
- Discussions: [GitHub Discussions](https://github.com/jeffallan/claude-skills/discussions)
