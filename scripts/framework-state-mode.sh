#!/bin/bash
#
# Framework state mode helper
#
# Centralizes repo_access decisions for local/private framework state.
# Team guidance and sprint contracts stay tracked in every mode.
#
# This script is intentionally dependency-light so hooks can call it.
#
# Usage: scripts/framework-state-mode.sh <command>
#

set -euo pipefail

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$PROJECT_DIR/manifest.md"

get_repo_access() {
    if [ -f "$MANIFEST" ]; then
        local value
        value=$(awk -F= '/^repo_access=/{print $2; exit}' "$MANIFEST" 2>/dev/null || true)
        if [ -n "${value:-}" ]; then
            printf '%s\n' "$value"
            return 0
        fi
    fi
    printf 'private-solo\n'
}

is_shared_mode() {
    case "$(get_repo_access)" in
        public|private-shared) return 0 ;;
        *) return 1 ;;
    esac
}

list_framework_paths() {
    printf '%s\n' \
        ".claude/settings.local.json" \
        ".claude/notebook.json" \
        ".claude/SNAPSHOT.md" \
        ".claude/context-snapshot.json" \
        ".claude/usage.log" \
        ".claude/logs" \
        "manifest.md"
}

list_tracked_framework_paths() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi

    git ls-files -- \
        .claude/settings.local.json \
        .claude/notebook.json \
        .claude/SNAPSHOT.md \
        .claude/context-snapshot.json \
        .claude/usage.log \
        .claude/logs \
        manifest.md 2>/dev/null || true
}

should_commit_framework_state() {
    printf 'false\n'
}

check_safe_mode() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi

    local tracked
    tracked="$(list_tracked_framework_paths)"
    if [ -n "$tracked" ]; then
        echo "framework-state: BLOCKER"
        echo "repo_access=$(get_repo_access), but local framework state files are still tracked:"
        echo "$tracked"
        echo "Run: scripts/switch-repo-access.sh $(get_repo_access)"
        return 2
    fi

    return 0
}

usage() {
    cat <<'EOF'
Usage: framework-state-mode.sh <command>

Commands:
  repo-access                    Print current repo_access value (default: private-solo)
  is-shared-mode                 Exit 0 if repo_access is public/private-shared
  should-commit-framework-state  Print true/false (used by hooks)
  tracked-framework-paths        List currently tracked framework files
  check-safe-mode                Exit 2 if any always-local framework state is tracked
EOF
}

COMMAND="${1:-}"

case "$COMMAND" in
    repo-access)
        get_repo_access
        ;;
    is-shared-mode)
        is_shared_mode
        ;;
    should-commit-framework-state)
        should_commit_framework_state
        ;;
    tracked-framework-paths)
        list_tracked_framework_paths
        ;;
    check-safe-mode)
        check_safe_mode
        ;;
    *)
        usage
        exit 1
        ;;
esac
