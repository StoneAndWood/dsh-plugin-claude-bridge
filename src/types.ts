/**
 * Type definitions for the Claude Code → DeepSeek Harness bridge plugin.
 * @module dsh-plugin-claude-bridge/types
 */

/** A parsed Claude Code memory entry. */
export interface MemoryEntry {
  /** Slug name from frontmatter or filename. */
  name: string
  /** One-line description from frontmatter. */
  description: string
  /** Metadata type: user | feedback | project | reference. */
  type: string
  /** Full content body (after frontmatter). */
  content: string
  /** Source file path for debugging. */
  sourcePath: string
}

/** A parsed Claude Code skill entry. */
export interface SkillEntry {
  /** Skill name from frontmatter. */
  name: string
  /** Skill description from frontmatter. */
  description: string
  /** Argument hint from frontmatter. */
  argumentHint?: string
  /** Skill level from frontmatter. */
  level?: number
  /** Full skill content body. */
  content: string
  /** Source file path. */
  sourcePath: string
}

/** Parsed YAML frontmatter result. */
export interface FrontmatterResult {
  meta: Record<string, string>
  body: string
}

/** Claude Code project info. */
export interface ClaudeProjectInfo {
  /** Path to Claude Code's projects directory. */
  projectsDir: string
  /** Encoded project key for the current working directory. */
  projectKey: string
  /** Path to the project's memory directory. */
  memoryDir: string
  /** Path to Claude Code's global skills directory. */
  skillsDir: string
  /** Path to Claude Code's global CLAUDE.md. */
  globalClaudeMd: string
}
