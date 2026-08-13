# dsh-plugin-claude-bridge

> Bridge [Claude Code](https://claude.ai/code)'s memory, skills, and configuration into [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) — zero migration, full compatibility.

[![npm](https://img.shields.io/npm/v/dsh-plugin-claude-bridge)](https://www.npmjs.com/package/dsh-plugin-claude-bridge)
[![dsh-plugin](https://img.shields.io/badge/topic-dsh-plugin-blue)](https://github.com/topics/dsh-plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What it does

This plugin reads Claude Code's standard file locations **directly** — no migration scripts, no file copying, no symlinks:

| Claude Code Location | What it does in dsh |
|---|---|
| `~/.claude/projects/<project>/memory/*.md` | Injects memories as dynamic system prompt context |
| `~/.claude/skills/<name>/SKILL.md` | Adds skills to the available catalog |
| `~/.claude/CLAUDE.md` | Injects global instructions into system prompt |

## Install

```sh
# From npm
dsh plugin --profile your-profile add dsh-plugin-claude-bridge

# From GitHub
dsh plugin --profile your-profile add github:YYTbit/dsh-plugin-claude-bridge
```

## Configuration

The plugin works out of the box with zero configuration. All options are optional:

```yaml
# In your profile's cordis.patch.yml
- id: claude-bridge
  name: dsh-plugin-claude-bridge
  config:
    # Path to Claude Code home (default: ~/.claude)
    claudeHome: '~/.claude'

    # Project key override (default: auto-detected from cwd)
    # projectKey: 'C--Users-yang'

    # Memory settings
    enableMemory: true
    maxMemoryBytes: 8192

    # Skills settings
    enableSkills: true
    maxSkills: 30

    # Global CLAUDE.md
    enableGlobalInstructions: true

    # Additional skill directories
    extraSkillDirs:
      - '~/.agents/skills'
```

## How it works

### Memory injection

Claude Code stores memories as individual markdown files with YAML frontmatter:

```markdown
---
name: my-lesson
description: Important lesson learned
metadata:
  type: feedback
---

The actual memory content...
```

This plugin reads all memory files from `~/.claude/projects/<encoded-path>/memory/`, sorts them by type priority (feedback > project > reference > user), and injects them as a dynamic system prompt context section. The context is re-read on each request, so new memories take effect immediately.

### Skill catalog

Skills from `~/.claude/skills/` are discovered and their names + descriptions are injected as a catalog in the system prompt. Full skill content is available when the agent needs to reference a specific skill.

### Global instructions

The content of `~/.claude/CLAUDE.md` is injected as an early system prompt section (order 5), so global instructions and model routing rules are preserved.

## Compatibility

| Feature | Claude Code | dsh + this plugin |
|---|---|---|
| CLAUDE.md (project) | ✅ Native | ✅ Native (dsh loads it directly) |
| CLAUDE.md (global) | ✅ Native | ✅ Via this plugin |
| Memory files | ✅ Native | ✅ Via this plugin |
| Skills | ✅ Native | ✅ Via this plugin |
| MCP servers | ✅ Native | ✅ Native (dsh has mcp-client) |

## Development

```sh
git clone https://github.com/YYTbit/dsh-plugin-claude-bridge
cd dsh-plugin-claude-bridge
npm install
npm run build
```

## License

MIT © YYTbit
