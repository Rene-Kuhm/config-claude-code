# Claude Code Enterprise - Onboarding Guide

Welcome! This guide will help you get the most out of your Claude Code enterprise setup.

## First Steps

### 1. Verify Installation

```bash
# Check Claude Code version
claude --version

# Verify configuration
~/.claude/scripts/validate.sh
```

### 2. Understand the Basics

Claude Code is an AI-powered CLI tool. You interact by typing prompts and it can:
- Read and write files
- Run terminal commands
- Search your codebase
- Generate code

### 3. Key Shortcuts

| Shortcut | Action |
|----------|--------|
| `Tab` | Toggle thinking mode |
| `Ctrl+C` | Cancel current operation |
| `Ctrl+R` | Search history |
| `Shift+Tab` | Toggle auto-accept mode |

## Daily Workflow

### Starting a Session

```bash
# Start in your project directory
cd ~/my-project
claude

# Or start with a specific task
claude "help me fix the login bug"
```

### Common Tasks

#### 1. Making Changes

```
You: "Add a loading spinner to the Button component"
```
Claude will:
- Read the current component
- Make the changes
- Show you a diff for approval

#### 2. Creating New Files

```
You: "Create a new UserProfile component"

# Or use scaffold skill
/scaffold component UserProfile
```

#### 3. Fixing Bugs

```
You: "There's an error in the checkout flow, the total shows NaN"
```
Claude will:
- Search for relevant code
- Identify the issue
- Propose a fix

#### 4. Git Operations

```bash
# Create a commit
/commit

# Create a pull request
/pr

# Review recent changes
git diff | claude "review these changes"
```

### Using Skills

Skills are pre-configured commands for common tasks:

```bash
# Development
/scaffold component Button    # Create component
/scaffold page dashboard      # Create page
/scaffold hook useAuth        # Create hook

# Git & PR
/commit                       # Conventional commit
/pr                          # Create pull request
/changelog generate 1.2.0    # Generate changelog

# Quality
/test generate src/file.ts   # Generate tests
/code-review src/file.ts     # Review code
/audit                       # Full project audit

# Documentation
/docs readme                 # Generate README
/docs api                    # Generate API docs
```

### Using Agents

Agents are specialized for specific tasks:

```
# For architecture questions
@architect "How should I structure the authentication system?"

# For security concerns
@security-auditor "Review this API endpoint for vulnerabilities"

# For testing strategy
@test-engineer "What tests should I write for this feature?"
```

## Best Practices

### 1. Be Specific

```
# ❌ Vague
"Fix the bug"

# ✅ Specific
"Fix the login timeout error that occurs when the server takes more than 5 seconds to respond"
```

### 2. Provide Context

```
# ❌ No context
"Add validation"

# ✅ With context
"Add email validation to the registration form in src/components/RegisterForm.tsx"
```

### 3. Use @-mentions for Files

```
You: "Update @src/config/database.ts to add connection pooling"
```

### 4. Review Before Accepting

- Always review diffs before accepting
- Use `Shift+Tab` to toggle auto-accept when confident
- Check generated tests actually test the right things

### 5. Leverage Skills

Instead of explaining what you want, use skills:

```bash
# Instead of: "Create a new component called ProductCard with props for..."
/scaffold component ProductCard
```

## Rules in Effect

Your setup has automatic rules that apply based on file type:

| Files | Rules Applied |
|-------|---------------|
| `*.ts`, `*.tsx` | TypeScript strict mode, no `any` |
| React components | Server/Client component rules |
| `app/api/**` | API security rules |
| `*.test.ts` | Testing best practices |
| All files | Security rules (always active) |

## Hooks in Effect

Automatic checks run on every operation:

| Hook | What it Does |
|------|--------------|
| `file-protection` | Blocks access to sensitive files |
| `compliance-check` | Warns about PII/secrets |
| `cost-estimator` | Estimates operation cost |
| `security-validator` | Validates security of prompts |

## Getting Help

### In Claude Code

```bash
/help              # General help
/context           # See what Claude knows
/doctor            # Diagnose issues
```

### Skills Reference

```bash
# List all available skills
ls ~/.claude/skills/

# Read a specific skill
cat ~/.claude/skills/commit/SKILL.md
```

## Troubleshooting

### "Permission Denied"

A hook is blocking the operation. Check:
```bash
# Recent hook blocks
grep "BLOCKED" ~/.claude/telemetry/logs/*.log
```

### "Tool Not Found"

MCP server may not be running:
```bash
# Check MCP status
/mcp
```

### Slow Performance

```bash
# Check costs and usage
/monitor costs
/monitor performance
```

## Next Steps

1. ✅ Read this guide
2. ⬜ Try `/scaffold component TestComponent`
3. ⬜ Make a change and use `/commit`
4. ⬜ Run `/audit` on your project
5. ⬜ Explore other skills with `ls ~/.claude/skills/`

---

*Happy coding with Claude Code Enterprise!*
