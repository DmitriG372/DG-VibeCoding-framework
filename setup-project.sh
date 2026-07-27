#!/usr/bin/env bash
set -euo pipefail

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=0
PROJECT_ARG=""

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    -h|--help)
      echo "Usage: setup-project.sh [--force] <project-dir>"
      exit 0
      ;;
    -*) echo "Unknown option: $arg" >&2; exit 64 ;;
    *)
      if [[ -n "$PROJECT_ARG" ]]; then
        echo "Only one project directory may be provided" >&2
        exit 64
      fi
      PROJECT_ARG="$arg"
      ;;
  esac
done

PROJECT_ARG="${PROJECT_ARG:-.}"

for tool in node git; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "setup-project: required tool not found: $tool" >&2
    exit 1
  }
done

mkdir -p "$PROJECT_ARG"
PROJECT_DIR="$(cd "$PROJECT_ARG" && pwd)"

has_content=0
if find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 ! -name '.dg-framework-backup-*' -print -quit | grep -q .; then
  has_content=1
fi

if [[ $has_content -eq 1 && $FORCE -ne 1 ]]; then
  echo "setup-project: $PROJECT_DIR is not empty; use --force to back up and replace framework files" >&2
  exit 1
fi

if [[ $has_content -eq 1 ]]; then
  BACKUP_DIR="$(mktemp -d "$PROJECT_DIR/.dg-framework-backup-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
  for item in \
    PROJECT.md CLAUDE.md AGENTS.md EXECUTION_PROTOCOL.md HOOKS.md framework.json \
    manifest.md .gitignore .claude .codex hooks scripts templates sprint; do
    if [[ -e "$PROJECT_DIR/$item" ]]; then
      cp -R "$PROJECT_DIR/$item" "$BACKUP_DIR/"
    fi
  done
  echo "setup-project: backup created at $BACKUP_DIR"
fi

node "$FRAMEWORK_DIR/scripts/install-framework.js" "$FRAMEWORK_DIR" "$PROJECT_DIR"
node "$FRAMEWORK_DIR/scripts/render-project-templates.js" "$PROJECT_DIR"
node "$PROJECT_DIR/scripts/verify-install.js" "$PROJECT_DIR" >/dev/null

VERSION="$(tr -d '\n' < "$FRAMEWORK_DIR/VERSION")"
echo "DG-VibeCoding Framework v$VERSION installed in $PROJECT_DIR"
echo "Next: edit PROJECT.md, initialize Git if needed, then just start working."
echo "sprint/sprint.json is optional and only needed to run CC and CX in parallel."
