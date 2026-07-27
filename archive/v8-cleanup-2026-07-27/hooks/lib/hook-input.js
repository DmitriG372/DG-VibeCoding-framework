const path = require('node:path');

const EDIT_TOOLS = new Set(['Edit', 'Write', 'MultiEdit', 'apply_patch']);

function extractPatchPaths(command) {
  if (typeof command !== 'string') return [];
  const paths = [];
  const pattern = /^\*\*\* (?:Add|Update|Delete) File: (.+)$/gm;
  for (const match of command.matchAll(pattern)) {
    const filePath = match[1].trim();
    if (filePath && !paths.includes(filePath)) paths.push(filePath);
  }
  return paths;
}

function normalizeHookInput(payload = {}, fallbackCwd = process.cwd()) {
  const toolInput = payload.tool_input && typeof payload.tool_input === 'object'
    ? payload.tool_input
    : {};
  const toolName = payload.tool_name || '';
  const isEdit = EDIT_TOOLS.has(toolName);
  const directPath = toolInput.file_path || toolInput.path || '';
  const filePaths = directPath
    ? [directPath]
    : toolName === 'apply_patch'
      ? extractPatchPaths(toolInput.command)
      : [];

  return {
    raw: payload,
    toolName,
    isEdit,
    command: typeof toolInput.command === 'string' ? toolInput.command : '',
    filePath: filePaths[0] || '',
    filePaths,
    cwd: payload.cwd || fallbackCwd,
    sessionId: payload.session_id || null,
  };
}

function resolveLocalNodeBinary(cwd, name, existsSync) {
  const candidate = path.join(cwd, 'node_modules', '.bin', name);
  return existsSync(candidate) ? candidate : null;
}

function getToolExitCode(payload = {}) {
  const response = payload.tool_response;
  if (!response || typeof response !== 'object') return null;
  if (Number.isInteger(response.exit_code)) return response.exit_code;
  if (Number.isInteger(response.status)) return response.status;
  return null;
}

function escapeMarkdownCell(value) {
  return String(value ?? '')
    .replace(/\|/g, '\\|')
    .replace(/[\r\n]+/g, ' ')
    .trim();
}

module.exports = {
  EDIT_TOOLS,
  escapeMarkdownCell,
  extractPatchPaths,
  getToolExitCode,
  normalizeHookInput,
  resolveLocalNodeBinary,
};
