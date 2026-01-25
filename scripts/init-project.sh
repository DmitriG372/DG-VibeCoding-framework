#!/bin/bash
# Wrapper for setup-project.sh
# Usage: ./scripts/init-project.sh /path/to/project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"

exec "$FRAMEWORK_DIR/setup-project.sh" "$@"
