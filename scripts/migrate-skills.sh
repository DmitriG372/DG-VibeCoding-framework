#!/bin/bash
# DG-VibeCoding-Framework - Skill Migration Script
# Migrate skills from flat files to subdirectory/SKILL.md format
# This makes skills visible to Claude Code
#
# Version loaded from VERSION file (or fallback)

# Get script directory to find VERSION file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"
VERSION=$(cat "$FRAMEWORK_DIR/VERSION" 2>/dev/null || echo "2.6")

SKILLS_DIR=".claude/skills"

if [ ! -d "$SKILLS_DIR" ]; then
    echo "Error: $SKILLS_DIR not found"
    exit 1
fi

echo "🔄 Migrating skills to subdirectory format..."

for file in "$SKILLS_DIR"/*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .md)

        # Skip if already in correct format
        if [ "$filename" = "SKILL" ]; then
            continue
        fi

        # Create subdirectory
        mkdir -p "$SKILLS_DIR/$filename"

        # Move and rename
        mv "$file" "$SKILLS_DIR/$filename/SKILL.md"

        echo "  ✓ $filename.md → $filename/SKILL.md"
    fi
done

echo ""
echo "✅ Migration complete!"
echo ""
echo "Skills structure:"
find "$SKILLS_DIR" -name "SKILL.md" -exec dirname {} \; | xargs -I {} basename {}
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 v${VERSION} Recommendation: Add 'context: fork' to token-intensive skills"
echo ""
echo "Example SKILL.md frontmatter:"
echo "  ---"
echo "  name: my-skill"
echo "  description: \"Skill description\""
echo "  context: fork        # CC 2.1.0: Runs in isolated sub-agent"
echo "  allowed-tools:       # CC 2.1.0: YAML-style list"
echo "    - Read"
echo "    - Edit"
echo "    - Bash"
echo "  ---"
echo ""
echo "Skills that benefit from context: fork:"
echo "  - sub-agent (orchestration, parallel execution)"
echo "  - database (type generation, large queries)"
echo "  - codex (external API calls)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
