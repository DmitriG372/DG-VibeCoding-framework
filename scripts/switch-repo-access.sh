#!/bin/bash
#
# Switch repo_access safely between private-solo and shared/public modes.
#
# Updates:
# - manifest.md repo_access value
# - .gitignore framework block (uncomment for shared/public, comment for solo)
# - git index (untracks framework files for shared/public)
#
# Does NOT rewrite history. If framework files are already in upstream history,
# the script stops and asks the user to perform a history rewrite or use a
# fresh shared/public branch.
#
# Usage: scripts/switch-repo-access.sh <private-solo|private-shared|public> [--commit]
#

set -euo pipefail

TARGET_MODE=""
COMMIT_CHANGES=false

for arg in "$@"; do
    case "$arg" in
        public|private-shared|private-solo)
            TARGET_MODE="$arg"
            ;;
        --commit)
            COMMIT_CHANGES=true
            ;;
        *)
            echo "Usage: scripts/switch-repo-access.sh <public|private-shared|private-solo> [--commit]" >&2
            exit 1
            ;;
    esac
done

if [ -z "$TARGET_MODE" ]; then
    echo "Usage: scripts/switch-repo-access.sh <public|private-shared|private-solo> [--commit]" >&2
    exit 1
fi

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$PROJECT_DIR/manifest.md"
GITIGNORE="$PROJECT_DIR/.gitignore"
HELPER="$PROJECT_DIR/scripts/framework-state-mode.sh"

if [ ! -f "$MANIFEST" ]; then
    echo "switch-repo-access: manifest.md not found at $MANIFEST" >&2
    exit 1
fi

if [ ! -f "$GITIGNORE" ]; then
    echo "switch-repo-access: .gitignore not found at $GITIGNORE" >&2
    exit 1
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "switch-repo-access: tracked/staged changes must be clean before switching modes" >&2
        exit 1
    fi
fi

# 1. Update manifest.md repo_access
awk -F= -v mode="$TARGET_MODE" '
    BEGIN { done=0 }
    /^repo_access=/ { print "repo_access=" mode; done=1; next }
    { print }
    END { if (!done) print "repo_access=" mode }
' "$MANIFEST" > "$MANIFEST.tmp"
mv "$MANIFEST.tmp" "$MANIFEST"

# 2. Toggle .gitignore framework block
awk -v enable="$TARGET_MODE" '
    BEGIN {
        inside=0
        uncomment=(enable=="public" || enable=="private-shared")
    }
    /^# >>> framework-public-ignore$/ { inside=1; print; next }
    /^# <<< framework-public-ignore$/ { inside=0; print; next }
    {
        if (inside && $0 ~ /^# / && $0 !~ /^# Uncomment these lines/) {
            if (uncomment) {
                sub(/^# /, "")
            }
        } else if (inside && $0 !~ /^# / && $0 !~ /^$/) {
            if (!uncomment) {
                $0 = "# " $0
            }
        }
        print
    }
' "$GITIGNORE" > "$GITIGNORE.tmp"
mv "$GITIGNORE.tmp" "$GITIGNORE"

# 3. Untrack framework files when switching to shared/public
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [ "$TARGET_MODE" = "public" ] || [ "$TARGET_MODE" = "private-shared" ]; then
        if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
            if git log --oneline '@{u}' -- .claude CLAUDE.md manifest.md AGENTS.md sprint 2>/dev/null | grep -q .; then
                echo "switch-repo-access: upstream history already contains framework files." >&2
                echo "Stop. Use history rewrite or start a fresh shared/public branch." >&2
                exit 2
            fi
        fi

        git rm -r --cached --ignore-unmatch .claude CLAUDE.md manifest.md AGENTS.md sprint >/dev/null 2>&1 || true
    fi

    if [ "$TARGET_MODE" = "public" ] || [ "$TARGET_MODE" = "private-shared" ]; then
        git add -- "$GITIGNORE" 2>/dev/null || true
    else
        git add -- "$MANIFEST" "$GITIGNORE"
    fi

    if [ "$COMMIT_CHANGES" = true ] && ! git diff --cached --quiet; then
        git commit -m "chore(repo-access): switch to $TARGET_MODE mode"
    fi
fi

echo "switch-repo-access: repo_access set to $TARGET_MODE"
if [ -x "$HELPER" ]; then
    echo "switch-repo-access: framework-state mode now = $("$HELPER" should-commit-framework-state 2>/dev/null || echo unknown)"
fi

if [ "$TARGET_MODE" = "public" ] || [ "$TARGET_MODE" = "private-shared" ]; then
    echo "switch-repo-access: framework files were untracked from the index when possible."
    echo "switch-repo-access: use a clean branch or rewrite history if those files were already pushed."
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && ! git diff --cached --quiet; then
    echo "switch-repo-access: staged transition detected."
    echo "switch-repo-access: commit it now or rerun with --commit for an explicit mode-switch commit."
fi
