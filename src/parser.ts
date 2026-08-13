/**
 * Frontmatter parser for Claude Code's markdown file format.
 * @module dsh-plugin-claude-bridge/parser
 */

import type { FrontmatterResult } from './types.ts'

/**
 * Parse YAML frontmatter from a markdown file.
 * Handles both standard `---\n...\n---` and `---\n...\n---\n` formats.
 */
export function parseFrontmatter(content: string): FrontmatterResult {
  const match = content.match(/^---[ \t]*\r?\n([\s\S]*?)\r?\n---[ \t]*\r?\n?([\s\S]*)$/)
  if (!match) return { meta: {}, body: content }

  const meta: Record<string, string> = {}
  let currentKey = ''
  let currentValue = ''

  for (const line of match[1].split(/\r?\n/)) {
    // Top-level key: value
    const kv = line.match(/^([A-Za-z][\w-]*):\s*(.*)$/)
    if (kv) {
      if (currentKey) meta[currentKey] = currentValue.trim()
      currentKey = kv[1]
      currentValue = kv[2]
    } else if (line.match(/^\s+/) && currentKey) {
      // Indented continuation (simple multi-line value support)
      currentValue += ' ' + line.trim()
    }
  }
  if (currentKey) meta[currentKey] = currentValue.trim()

  return { meta, body: match[2].trim() }
}

/**
 * Extract the `metadata.type` from frontmatter.
 * Claude Code uses nested YAML like `metadata:\n  type: feedback`
 * but our simple parser flattens it, so we check both formats.
 */
export function extractMetadataType(meta: Record<string, string>): string {
  // Direct type field
  if (meta.type) return meta.type
  // metadata field that might contain "type: xxx"
  if (meta.metadata) {
    const typeMatch = meta.metadata.match(/type:\s*(\w+)/)
    if (typeMatch) return typeMatch[1]
  }
  return 'unknown'
}
