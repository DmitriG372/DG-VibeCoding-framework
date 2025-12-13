#!/bin/bash
# Migrate skills from flat files to subdirectory/SKILL.md format
# This makes skills visible to Claude Code

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
