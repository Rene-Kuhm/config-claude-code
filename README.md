# Claude Code Enterprise Configuration

This is your enterprise-grade Claude Code configuration with advanced features for professional development.

## Overview

| Component | Count | Description |
|-----------|-------|-------------|
| Agents | 8 | Specialized AI assistants |
| Skills | 20 | Invocable capabilities |
| Rules | 7 | Context-aware guidelines |
| Commands | 6 | Quick actions |
| Hooks | 8 | Automated triggers |
| MCP Servers | 19 | External integrations |
| Templates | 10+ | Reusable templates |

## Quick Reference

### Most Used Skills

```bash
/commit              # Create conventional commit
/pr                  # Create pull request
/test generate       # Generate tests for file
/scaffold component  # Create component boilerplate
/audit               # Run project audit
/code-review         # Review code/PR
```

### Agents

| Agent | Use Case |
|-------|----------|
| `@architect` | System design, SOLID analysis |
| `@builder` | Implementation, coding |
| `@debugger` | Error resolution |
| `@security-auditor` | Security review |
| `@docs-writer` | Documentation |
| `@test-engineer` | Testing strategy |

### Active Hooks

| Event | Hooks |
|-------|-------|
| PreToolUse | file-protection, compliance-check, cost-estimator |
| PostToolUse | team-notification |
| UserPromptSubmit | security-validator |
| Stop | team-notification |

## Directory Structure

```
~/.claude/
├── agents/           # AI agent definitions
├── skills/           # Invocable skills (/command)
├── rules/            # Context-aware rules
├── commands/         # Slash commands
├── hooks/            # Event triggers
├── output-styles/    # Response styles
├── templates/        # Reusable templates
├── teams/            # Team configuration
├── alerts/           # Alerting rules
├── scripts/          # Automation scripts
├── telemetry/        # Usage tracking
├── CLAUDE.md         # Global instructions
├── settings.json     # Main configuration
└── README.md         # This file
```

## Configuration Files

### settings.json

Main configuration including:
- Permission rules (allow/deny)
- Hook configurations
- MCP server definitions
- Plugin settings

### CLAUDE.md

Global instructions that apply to all projects:
- TypeScript standards
- Naming conventions
- Security guidelines
- Tool preferences

## Environment Variables

For full functionality, configure these:

```bash
# Notifications
export CLAUDE_SLACK_WEBHOOK="https://hooks.slack.com/..."
export CLAUDE_TEAMS_WEBHOOK="https://outlook.office.com/..."

# MCP Servers
export SLACK_BOT_TOKEN="xoxb-..."
export SLACK_TEAM_ID="T..."
export LINEAR_API_KEY="lin_api_..."
```

## Maintenance

### Validate Configuration

```bash
~/.claude/scripts/validate.sh
```

### Backup Configuration

```bash
~/.claude/scripts/backup.sh
```

### Update/Restore

```bash
# Backup before updates
~/.claude/scripts/backup.sh

# Restore if needed
~/.claude/scripts/restore.sh latest
```

## Customization

### Adding a New Skill

1. Create directory: `~/.claude/skills/my-skill/`
2. Create `SKILL.md` with frontmatter
3. Restart Claude Code

### Adding a New Rule

1. Create file: `~/.claude/rules/my-rule.md`
2. Rules auto-load based on context

### Adding a New Hook

1. Create script in `~/.claude/hooks/`
2. Make executable: `chmod +x hook.sh`
3. Add to `settings.json` hooks section

## Support

- Documentation: https://code.claude.com/docs
- Issues: https://github.com/anthropics/claude-code/issues

---

## Installation

```bash
# Clone this repo
git clone https://github.com/Rene-Kuhm/claude-code-config.git

# Copy to your Claude Code config directory
cp -r claude-code-config/* ~/.claude/

# Make scripts executable
chmod +x ~/.claude/scripts/*.sh
chmod +x ~/.claude/hooks/*.sh

# Validate configuration
~/.claude/scripts/validate.sh
```

## License

MIT

---

*Enterprise Configuration v1.0.0*
*By Rene-Kuhm*
*Last Updated: 2026-01-01*
