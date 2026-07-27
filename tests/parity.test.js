const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const ROOT = path.resolve(__dirname, '..');
const read = relative => fs.readFileSync(path.join(ROOT, relative), 'utf8');
const readJson = relative => JSON.parse(read(relative));

const CONTRACT = 'core/AGENTS.md';
const CLAUDE_ENTRY = 'core/CLAUDE.md';

// Anthropic documents a 200-line adherence target for CLAUDE.md; the shared
// contract has to stay well inside it because Codex loads the same bytes.
const CONTRACT_MAX_LINES = 150;
const CLAUDE_ENTRY_MAX_LINES = 20;

const lineCount = text => text.trimEnd().split('\n').length;

/** event -> sorted hook commands, so the two runtimes can be compared directly. */
function hookCommandsByEvent(settings) {
  const result = {};
  for (const [event, groups] of Object.entries(settings.hooks || {})) {
    result[event] = groups
      .flatMap(group => (group.hooks || []).map(hook => hook.command))
      .sort();
  }
  return result;
}

test('CLAUDE.md imports the shared contract on its first line', () => {
  const first = read(CLAUDE_ENTRY).split('\n')[0].trim();
  assert.equal(first, '@AGENTS.md',
    'Claude Code does not read AGENTS.md natively; the import is what makes the contract shared.');
});

test('the shared contract stays inside the adherence budget', () => {
  assert.ok(lineCount(read(CONTRACT)) <= CONTRACT_MAX_LINES,
    `${CONTRACT} must be <= ${CONTRACT_MAX_LINES} lines`);
  assert.ok(lineCount(read(CLAUDE_ENTRY)) <= CLAUDE_ENTRY_MAX_LINES,
    `${CLAUDE_ENTRY} must be <= ${CLAUDE_ENTRY_MAX_LINES} lines`);
});

test('both runtimes wire exactly the same hooks', () => {
  const claude = hookCommandsByEvent(readJson('core/settings.template.json'));
  const codex = hookCommandsByEvent(readJson('core/codex-hooks.template.json'));

  assert.deepEqual(Object.keys(claude).sort(), Object.keys(codex).sort(),
    'a lifecycle event wired for one agent but not the other is a parity gap');

  for (const event of Object.keys(claude)) {
    assert.deepEqual(claude[event], codex[event], `hook set differs for ${event}`);
  }
});

test('every wired hook file exists', () => {
  for (const settings of ['core/settings.template.json', 'core/codex-hooks.template.json']) {
    for (const commands of Object.values(hookCommandsByEvent(readJson(settings)))) {
      for (const command of commands) {
        const file = command.replace(/^node \.\//, '');
        assert.ok(fs.existsSync(path.join(ROOT, file)), `${settings} wires missing ${file}`);
      }
    }
  }
});

test('no hook runs on an edit', () => {
  // A per-edit hook is what turned every code change into a project-wide check.
  for (const settings of ['core/settings.template.json', 'core/codex-hooks.template.json']) {
    for (const groups of Object.values(readJson(settings).hooks || {})) {
      for (const group of groups) {
        assert.ok(!/Edit|Write|MultiEdit|apply_patch/.test(group.matcher || ''),
          `${settings} still wires a hook on ${group.matcher}`);
      }
    }
  }
});

test('installed commands delegate to a section that exists in the contract', () => {
  const headings = new Set(
    read(CONTRACT).split('\n')
      .filter(line => line.startsWith('## '))
      .map(line => line.slice(3).trim())
  );

  for (const name of readJson('framework.json').core.commands) {
    const body = read(`.claude/commands/${name}.md`);
    const referenced = [...body.matchAll(/`## ([^`]+)`/g)].map(match => match[1].trim());
    assert.ok(referenced.length > 0, `/${name} must delegate to an AGENTS.md section`);
    for (const section of referenced) {
      assert.ok(headings.has(section), `/${name} points at missing section "## ${section}"`);
    }
  }
});

test('the install manifest ships nothing Codex cannot read', () => {
  const framework = readJson('framework.json');
  const targets = framework.install.entries.map(entry => entry.to);

  for (const forbidden of ['.claude/rules', '.claude/skills']) {
    assert.ok(!targets.some(target => target.startsWith(forbidden)),
      `${forbidden} is invisible to Codex, so the framework must not ship it`);
  }

  assert.deepEqual(framework.core.skills, [],
    'a framework-level skill is capability Codex would not have');
});

test('the retired v8 machinery is gone from the live tree', () => {
  const retired = [
    'hooks/decomposition-guard.js',
    'hooks/type-check.js',
    'hooks/auto-format.js',
    'hooks/plan-to-sprint.js',
    'hooks/context-monitor.js',
    'hooks/sprint-sync.js',
    'core/EXECUTION_PROTOCOL.md',
    'core/HOOKS.md',
  ];
  for (const file of retired) {
    assert.ok(!fs.existsSync(path.join(ROOT, file)), `${file} should be archived, not live`);
  }
  assert.ok(!fs.existsSync(path.join(ROOT, '.claude/rules')) ||
    fs.readdirSync(path.join(ROOT, '.claude/rules')).length === 0,
    '.claude/rules must be empty — the framework ships no rules');
});
