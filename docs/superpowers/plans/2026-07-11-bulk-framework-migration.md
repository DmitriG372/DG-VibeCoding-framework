# Bulk Framework Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a safe, dependency-free bulk updater that recursively discovers DG-VibeCoding projects, excludes configured paths, plans by default, and sequentially delegates eligible 7.x projects to the existing single-project migrator.

**Architecture:** A small Node.js CLI delegates to focused modules for ignore matching, discovery/preflight, reporting/locking, and migration orchestration. `migrate-project.sh` remains the only migration implementation; the bulk layer enforces policy, invokes it with `shell: false`, validates results, and records bounded reports outside the scan root.

**Tech Stack:** Node.js built-ins (`fs`, `path`, `os`, `crypto`, `child_process`, `readline`), existing Bash migration, `node:test`, ShellCheck.

## Global Constraints

- Default invocation is read-only dry-run; mutation requires `--apply`.
- Dirty repositories, linked worktrees, symlinks, detached heads, and active Git operations are never migrated.
- Discovery is recursive, deterministic, and never follows symbolic links.
- Exclusions combine `.dg-framework-ignore`, repeated `--exclude`, and non-negatable built-ins.
- Automatic migration supports only identified DG-VibeCoding 7.x repositories to the current `VERSION`.
- Migration is sequential and stops after the first failure unless `--continue-on-error` is explicit.
- No network, dependency installation, commit, push, pull, stash, or automatic destructive rollback.
- Child processes use argument arrays with `shell: false`.
- Locks and reports live outside the scan root.
- No new runtime dependency may be added.

## File Map

- Create `scripts/lib/bulk-ignore.js` — normalization and supported ignore-pattern matching.
- Create `scripts/lib/bulk-migration.js` — discovery, Git/framework classification, recheck, and migration invocation.
- Create `scripts/lib/bulk-report.js` — external lock, bounded JSON record, and Markdown report.
- Create `scripts/bulk-migrate.js` — CLI parsing, source validation, confirmation, signals, and exit codes.
- Create `tests/bulk-ignore.test.js` and `tests/bulk-migration.test.js` — unit and temporary-repository integration coverage.
- Modify `framework.json`, `tests/framework-consistency.sh`, and `tests/run.sh` — register the central tool and its tests without copying it into target projects.
- Modify `README.md`, `GUIDE.md`, and `CHANGELOG.md` — operational documentation.

---

### Task 1: Exclusion Pattern Engine

**Files:**
- Create: `scripts/lib/bulk-ignore.js`
- Create: `tests/bulk-ignore.test.js`

**Interfaces:**
- Produces: `BUILT_IN_PATTERNS: readonly string[]`
- Produces: `normalizeRelative(root: string, candidate: string): string`
- Produces: `parsePatterns(text: string): string[]`
- Produces: `compilePattern(pattern: string): RegExp`
- Produces: `isExcluded(relativePath: string, patterns: string[]): boolean`
- Produces: `loadPatterns(root: string, cliPatterns: string[]): { patterns: string[], ignoreFile: string | null }`

- [ ] **Step 1: Write failing normalization and parser tests**

Create `tests/bulk-ignore.test.js`:

```js
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

const {
  BUILT_IN_PATTERNS,
  normalizeRelative,
  parsePatterns,
  compilePattern,
  isExcluded,
} = require('../scripts/lib/bulk-ignore');

test('normalizes contained paths to POSIX relative paths', () => {
  const root = path.resolve('/tmp/projects');
  assert.equal(normalizeRelative(root, path.join(root, 'group', 'app')), 'group/app');
});

test('rejects paths outside the scan root', () => {
  assert.throws(() => normalizeRelative('/tmp/projects', '/tmp/other'), /outside scan root/);
});

test('parses comments and blank lines without allowing negation', () => {
  assert.deepEqual(parsePatterns('# note\narchive/**\n\n**/legacy-*\n'), [
    'archive/**',
    '**/legacy-*',
  ]);
  assert.throws(() => parsePatterns('!archive/keep\n'), /negation is not supported/);
});

test('ships non-negatable safety patterns', () => {
  assert.ok(BUILT_IN_PATTERNS.includes('**/node_modules/**'));
  assert.ok(BUILT_IN_PATTERNS.includes('**/.dg-framework-backup-*/**'));
});
```

- [ ] **Step 2: Run tests and verify RED**

Run: `node --test tests/bulk-ignore.test.js`

Expected: FAIL with `Cannot find module '../scripts/lib/bulk-ignore'`.

- [ ] **Step 3: Implement normalization and parsing**

Create `scripts/lib/bulk-ignore.js` with:

```js
const fs = require('node:fs');
const path = require('node:path');

const BUILT_IN_PATTERNS = Object.freeze([
  '**/.git/**',
  '**/node_modules/**',
  '**/dist/**',
  '**/build/**',
  '**/.next/**',
  '**/.vercel/**',
  '**/.dg-framework-backup-*/**',
  '**/.dg-framework-reports/**',
]);

function normalizeRelative(root, candidate) {
  const relative = path.relative(path.resolve(root), path.resolve(candidate));
  if (relative === '..' || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) {
    throw new Error(`path outside scan root: ${candidate}`);
  }
  return relative.split(path.sep).join('/');
}

function parsePatterns(text) {
  const patterns = [];
  for (const rawLine of text.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    if (line.startsWith('!')) throw new Error(`pattern negation is not supported: ${line}`);
    if (line.includes('\0')) throw new Error('exclude pattern contains NUL');
    patterns.push(line.replace(/^\.\//, ''));
  }
  return patterns;
}
```

- [ ] **Step 4: Add failing matcher tests**

Append:

```js
test('matches root-relative and recursive globs', () => {
  const patterns = ['archive/**', '**/legacy-*', 'client-project'];
  assert.equal(isExcluded('archive/old/app', patterns), true);
  assert.equal(isExcluded('group/legacy-api', patterns), true);
  assert.equal(isExcluded('group/client-project/src', patterns), true);
  assert.equal(isExcluded('active/app', patterns), false);
});

test('treats regex punctuation as literal path data', () => {
  const regex = compilePattern('group/app+[1]/**');
  assert.equal(regex.test('group/app+[1]/src'), true);
  assert.equal(regex.test('group/appp1/src'), false);
});
```

Run: `node --test tests/bulk-ignore.test.js`

Expected: FAIL because `compilePattern` and `isExcluded` are absent.

- [ ] **Step 5: Implement the glob subset and ignore-file loading**

Add a character-by-character compiler and exports:

```js
function globSource(glob) {
  let source = '';
  for (let index = 0; index < glob.length; index += 1) {
    const char = glob[index];
    if (char === '*' && glob[index + 1] === '*') {
      if (glob[index + 2] === '/') {
        source += '(?:.*/)?';
        index += 2;
      } else {
        source += '.*';
        index += 1;
      }
    } else if (char === '*') source += '[^/]*';
    else if (char === '?') source += '[^/]';
    else if ('\\.^$+()[]{}|'.includes(char)) source += `\\${char}`;
    else source += char;
  }
  return source;
}

function compilePattern(rawPattern) {
  const pattern = rawPattern.replace(/^\//, '').replace(/\/$/, '');
  const prefix = pattern.includes('/') ? '^' : '(?:^|.*/)';
  return new RegExp(`${prefix}${globSource(pattern)}(?:/.*)?$`);
}

function isExcluded(relativePath, patterns) {
  const normalized = relativePath.replaceAll('\\', '/').replace(/^\.\//, '');
  return patterns.some(pattern => compilePattern(pattern).test(normalized));
}

function loadPatterns(root, cliPatterns = []) {
  const ignorePath = path.join(root, '.dg-framework-ignore');
  const exists = fs.existsSync(ignorePath);
  const fromFile = exists ? parsePatterns(fs.readFileSync(ignorePath, 'utf8')) : [];
  return {
    patterns: [...BUILT_IN_PATTERNS, ...fromFile, ...parsePatterns(cliPatterns.join('\n'))],
    ignoreFile: exists ? ignorePath : null,
  };
}

module.exports = {
  BUILT_IN_PATTERNS,
  normalizeRelative,
  parsePatterns,
  compilePattern,
  isExcluded,
  loadPatterns,
};
```

Run: `node --test tests/bulk-ignore.test.js`

Expected: all tests PASS.

- [ ] **Step 6: Commit Task 1**

```bash
git add scripts/lib/bulk-ignore.js tests/bulk-ignore.test.js
git commit -m "feat(migration): add bulk exclusion engine"
```

---

### Task 2: Discovery and Git Preflight

**Files:**
- Create: `scripts/lib/bulk-migration.js`
- Create: `tests/bulk-migration.test.js`

**Interfaces:**
- Consumes: `normalizeRelative`, `isExcluded` from Task 1.
- Produces: `runProcess(command, args, options): { status, stdout, stderr }`
- Produces: `discoverCandidates(root, patterns): Candidate[]`
- Produces: `classifyVersion(version, currentVersion): string`
- Produces: `preflightCandidate(candidate, context): ProjectRecord`
- Produces: `buildPlan(options): RunRecord`

`Candidate.gitKind` is one of `repo`, `worktree`, or `excluded`. An excluded
candidate is never opened beyond checking its direct `.git` marker.

- [ ] **Step 1: Write failing real-filesystem discovery tests**

Create `tests/bulk-migration.test.js`:

```js
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const { discoverCandidates } = require('../scripts/lib/bulk-migration');

function tempRoot() {
  return fs.mkdtempSync(path.join(os.tmpdir(), 'dg-bulk-test-'));
}

function frameworkMarker(project, version = '7.1.0') {
  fs.writeFileSync(path.join(project, 'framework.json'), JSON.stringify({
    name: 'DG-VibeCoding-Framework',
    version,
  }));
}

test('discovers repositories recursively in stable order and prunes repo contents', () => {
  const root = tempRoot();
  const alpha = path.join(root, 'group', 'alpha');
  const beta = path.join(root, 'beta');
  fs.mkdirSync(path.join(alpha, '.git'), { recursive: true });
  fs.mkdirSync(path.join(beta, '.git'), { recursive: true });
  fs.mkdirSync(path.join(alpha, 'nested', '.git'), { recursive: true });
  frameworkMarker(alpha);
  frameworkMarker(beta);
  assert.deepEqual(discoverCandidates(root, []).map(item => item.relativePath), [
    'beta',
    'group/alpha',
  ]);
});

test('classifies linked worktrees and never follows symlinks', () => {
  const root = tempRoot();
  const linked = path.join(root, 'linked');
  const real = path.join(root, 'real');
  fs.mkdirSync(linked, { recursive: true });
  fs.writeFileSync(path.join(linked, '.git'), 'gitdir: /tmp/common/worktrees/linked\n');
  frameworkMarker(linked);
  fs.mkdirSync(path.join(real, '.git'), { recursive: true });
  frameworkMarker(real);
  fs.symlinkSync(real, path.join(root, 'alias'));
  assert.deepEqual(discoverCandidates(root, []).map(item => [item.relativePath, item.gitKind]), [
    ['linked', 'worktree'],
    ['real', 'repo'],
  ]);
});

test('reports an excluded repository without descending into it', () => {
  const root = tempRoot();
  const excluded = path.join(root, 'archive', 'old-app');
  fs.mkdirSync(path.join(excluded, '.git'), { recursive: true });
  fs.mkdirSync(path.join(excluded, 'nested', '.git'), { recursive: true });
  frameworkMarker(excluded);
  assert.deepEqual(discoverCandidates(root, ['archive/**']).map(item => [
    item.relativePath,
    item.gitKind,
  ]), [['archive/old-app', 'excluded']]);
});
```

- [ ] **Step 2: Run tests and verify RED**

Run: `node --test tests/bulk-migration.test.js`

Expected: FAIL with missing `scripts/lib/bulk-migration.js`.

- [ ] **Step 3: Implement safe process execution and discovery**

Create `scripts/lib/bulk-migration.js`. Use this process boundary:

```js
const { spawnSync } = require('node:child_process');

function runProcess(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: options.cwd,
    encoding: 'utf8',
    shell: false,
    maxBuffer: 1024 * 1024,
    input: options.input,
  });
  return {
    status: result.status ?? 1,
    stdout: result.stdout || '',
    stderr: result.stderr || result.error?.message || '',
  };
}
```

Implement `discoverCandidates` as a synchronous, lexically sorted walker using
`readdirSync(..., { withFileTypes: true })` and `lstatSync`. It must skip
symlinks and identify `.git` directory/file. When an exclusion matches, inspect
only whether that directory directly contains `.git`; if so append it with
`gitKind: 'excluded'`, then prune it. For non-excluded repos collect weak markers
(`AGENTS.md`, `CLAUDE.md`, `.claude`, `.tasks/board.md`), append the candidate,
and prune that repository subtree.

- [ ] **Step 4: Add failing version and Git-state tests**

Add:

```js
const { classifyVersion, preflightCandidate } = require('../scripts/lib/bulk-migration');

test('classifies only 7.x as automatically eligible', () => {
  assert.equal(classifyVersion('7.1.0', '8.0.0'), 'eligible');
  assert.equal(classifyVersion('8.0.0', '8.0.0'), 'current');
  assert.equal(classifyVersion('6.9.0', '8.0.0'), 'unsupported');
  assert.equal(classifyVersion('9.0.0', '8.0.0'), 'unsupported');
});

test('marks any porcelain output dirty', () => {
  const project = tempRoot();
  fs.mkdirSync(path.join(project, '.git'));
  frameworkMarker(project);
  const runner = (_command, args) => {
    if (args[0] === 'status') return { status: 0, stdout: '?? local.txt\n', stderr: '' };
    if (args[0] === 'symbolic-ref') return { status: 0, stdout: 'main\n', stderr: '' };
    if (args[0] === 'rev-parse' && args[1] === 'HEAD') return { status: 0, stdout: 'abc123\n', stderr: '' };
    return { status: 0, stdout: '', stderr: '' };
  };
  const record = preflightCandidate(
    { path: project, relativePath: 'project', gitKind: 'repo', weakMarkers: [] },
    { currentVersion: '8.0.0', runner }
  );
  assert.equal(record.status, 'dirty');
});
```

Add companion cases for `gitKind: 'excluded'` → `excluded`, `.git` file → `worktree`, failed `symbolic-ref` →
`detached`, operation marker → `git_operation`, invalid identity →
`manual_review`, current version → `current`, and clean 7.x → `eligible`.

- [ ] **Step 5: Implement classification and plan construction**

Use:

```js
function classifyVersion(version, currentVersion) {
  if (version === currentVersion) return 'current';
  if (/^7\.[0-9]+\.[0-9]+$/.test(version)) return 'eligible';
  return 'unsupported';
}
```

Classify in this order: worktree, framework identity/JSON, version, branch,
active Git operation, dirty status, HEAD. Call Git only through argument arrays:

```js
runner('git', ['symbolic-ref', '--quiet', '--short', 'HEAD'], { cwd: candidate.path });
runner('git', ['status', '--porcelain', '--untracked-files=all'], { cwd: candidate.path });
runner('git', ['rev-parse', 'HEAD'], { cwd: candidate.path });
runner('git', ['rev-parse', '--git-path', marker], { cwd: candidate.path });
```

Check `MERGE_HEAD`, `CHERRY_PICK_HEAD`, `REVERT_HEAD`, `rebase-merge`, and
`rebase-apply`. `buildPlan` returns schema version 1, mode `plan`, root,
framework version, timestamps, patterns, projects, calculated status counts,
and null exit code.

Run: `node --test tests/bulk-ignore.test.js tests/bulk-migration.test.js`

Expected: all tests PASS.

- [ ] **Step 6: Commit Task 2**

```bash
git add scripts/lib/bulk-migration.js tests/bulk-migration.test.js
git commit -m "feat(migration): discover and classify framework projects"
```

---

### Task 3: External Lock and Bounded Reports

**Files:**
- Create: `scripts/lib/bulk-report.js`
- Modify: `tests/bulk-migration.test.js`

**Interfaces:**
- Produces: `defaultReportDir(env, home): string`
- Produces: `assertOutsideRoot(root, target): void`
- Produces: `lockPathFor(root, tempDir): string`
- Produces: `acquireLock(root, options): LockHandle`
- Produces: `boundText(value, maxBytes): string`
- Produces: `renderMarkdown(record): string`
- Produces: `writeReports(record, reportDir): { jsonPath, markdownPath }`

- [ ] **Step 1: Write failing path, lock, and truncation tests**

Add:

```js
const {
  defaultReportDir,
  assertOutsideRoot,
  lockPathFor,
  acquireLock,
  boundText,
} = require('../scripts/lib/bulk-report');

test('keeps default reports outside the scan root', () => {
  assert.equal(defaultReportDir({ XDG_STATE_HOME: '/state' }, '/home/user'),
    '/state/dg-vibecoding/bulk-migrate');
  assert.throws(() => assertOutsideRoot('/projects', '/projects/reports'), /inside scan root/);
});

test('derives a stable root-specific lock path', () => {
  assert.equal(lockPathFor('/projects', '/tmp'), lockPathFor('/projects', '/tmp'));
  assert.notEqual(lockPathFor('/projects', '/tmp'), lockPathFor('/other', '/tmp'));
});

test('refuses an existing lock without deleting it', () => {
  const root = tempRoot();
  const tempDir = tempRoot();
  const first = acquireLock(root, { tempDir, pid: process.pid, now: () => new Date(0) });
  assert.throws(() => acquireLock(root, { tempDir }), /bulk migration lock exists/);
  first.release();
});

test('bounds command output by UTF-8 byte size', () => {
  const output = boundText('x'.repeat(9000), 100);
  assert.match(output, /truncated/);
  assert.ok(Buffer.byteLength(output) < 160);
});
```

- [ ] **Step 2: Run tests and verify RED**

Run: `node --test tests/bulk-migration.test.js`

Expected: FAIL with missing `scripts/lib/bulk-report.js`.

- [ ] **Step 3: Implement external state paths and lock ownership**

Use SHA-256 of the real root and atomic directory creation:

```js
function lockPathFor(root, tempDir = os.tmpdir()) {
  const digest = crypto.createHash('sha256')
    .update(fs.realpathSync(root)).digest('hex').slice(0, 16);
  return path.join(tempDir, `dg-framework-bulk-${digest}.lock`);
}

function acquireLock(root, { tempDir = os.tmpdir(), pid = process.pid, now = () => new Date() } = {}) {
  const lockPath = lockPathFor(root, tempDir);
  try {
    fs.mkdirSync(lockPath);
  } catch (error) {
    if (error.code === 'EEXIST') {
      throw new Error(`bulk migration lock exists: ${lockPath}; inspect and remove it manually if stale`);
    }
    throw error;
  }
  fs.writeFileSync(path.join(lockPath, 'owner.json'), `${JSON.stringify({
    pid,
    startedAt: now().toISOString(),
    root: fs.realpathSync(root),
  }, null, 2)}\n`);
  let released = false;
  return {
    path: lockPath,
    release() {
      if (released) return;
      fs.rmSync(lockPath, { recursive: true, force: true });
      released = true;
    },
  };
}
```

`assertOutsideRoot` uses the containment rule from Task 1.
`defaultReportDir` uses `XDG_STATE_HOME` or `<home>/.local/state`.

- [ ] **Step 4: Add failing report serialization tests**

Create a record with `eligible`, `dirty`, `failed`, and `updated` projects.
Assert that canonical JSON parses, Markdown contains counts and reasons, command
outputs are bounded, and neither a supplied environment secret nor source-file
content appears.

Run: `node --test tests/bulk-migration.test.js`

Expected: FAIL because report functions are absent.

- [ ] **Step 5: Implement canonical JSON and derived Markdown**

`writeReports` creates the directory, calls `assertOutsideRoot` before writing,
uses a filename-safe timestamp, writes JSON through a same-directory temporary
file and atomic rename, then derives Markdown only from the record. The table
columns are `Project`, `Before`, `After`, `Status`, `Reason`, and `Backup`.

Run: `node --test tests/bulk-migration.test.js`

Expected: all report and lock tests PASS.

- [ ] **Step 6: Commit Task 3**

```bash
git add scripts/lib/bulk-report.js tests/bulk-migration.test.js
git commit -m "feat(migration): add bulk locks and audit reports"
```

---

### Task 4: Sequential Apply Orchestrator and CLI

**Files:**
- Create: `scripts/bulk-migrate.js`
- Modify: `scripts/lib/bulk-migration.js`
- Modify: `tests/bulk-migration.test.js`

**Interfaces:**
- Produces from library: `recheckCandidate(record, context): ProjectRecord`
- Produces from library: `migrateCandidate(record, context): ProjectRecord`
- Produces from library: `applyPlan(record, context): Promise<RunRecord>`
- Produces from CLI: `parseArgs(argv): CliOptions`
- Produces from CLI: `validateFrameworkSource(frameworkRoot, runner): void`
- Produces from CLI: `main(argv, dependencies): Promise<number>`

`main` accepts only these injectable dependency keys: `runner`, `confirm`,
`acquireLock`, `writeReports`, `now`, `env`, `home`, `tempDir`, `frameworkRoot`,
`stdout`, `stderr`, and `registerSignalHandlers`. Production defaults are used
for omitted keys; there is no environment or CLI test mode.

- [ ] **Step 1: Write failing CLI parser tests**

Add to `tests/bulk-migration.test.js`:

```js
const { parseArgs } = require('../scripts/bulk-migrate');

test('parses safe defaults and repeated excludes', () => {
  assert.deepEqual(
    parseArgs(['/projects', '--exclude', 'archive/**', '--exclude', '**/legacy-*']),
    {
      root: path.resolve('/projects'),
      apply: false,
      yes: false,
      continueOnError: false,
      excludes: ['archive/**', '**/legacy-*'],
      reportDir: null,
      help: false,
    }
  );
});

test('rejects non-interactive confirmation without apply', () => {
  assert.throws(() => parseArgs(['/projects', '--yes']), /--yes requires --apply/);
});
```

Add cases for `--apply`, `--continue-on-error`, `--report-dir`, `--help`,
unknown options, missing option values, and more than one positional root.

- [ ] **Step 2: Run parser tests and verify RED**

Run: `node --test tests/bulk-migration.test.js`

Expected: FAIL because `scripts/bulk-migrate.js` does not exist.

- [ ] **Step 3: Implement argument parsing and source validation**

Create executable `scripts/bulk-migrate.js` with a forward-only argument loop.
It must never evaluate or concatenate arguments into a shell command.

`validateFrameworkSource` must:

```js
const version = fs.readFileSync(path.join(frameworkRoot, 'VERSION'), 'utf8').trim();
const framework = JSON.parse(fs.readFileSync(path.join(frameworkRoot, 'framework.json'), 'utf8'));
if (framework.version !== version) throw new Error('framework source version mismatch');
for (const entry of framework.install.entries) {
  if (!fs.existsSync(path.join(frameworkRoot, entry.from))) {
    throw new Error(`framework install source missing: ${entry.from}`);
  }
}
const status = runner('git', ['status', '--porcelain', '--untracked-files=all'], {
  cwd: frameworkRoot,
});
if (status.status !== 0 || status.stdout.trim()) {
  throw new Error('framework source must be clean before apply');
}
```

Dry-run mode may report a dirty source but must remain usable and read-only.

- [ ] **Step 4: Write failing sequential apply tests**

Build a frozen plan with two eligible records. Inject a runner that records
`{ command, args, cwd }`, returns `migration complete; backup: <path>`, and
returns success for both validators. Assert:

- calls are sequential;
- every path with spaces or shell metacharacters is one argument;
- no call requests `shell: true`;
- backup and after-version are recorded;
- state changed to dirty becomes `changed_since_plan`;
- the second project is not invoked after the first failure;
- `continueOnError: true` invokes it but final exit code remains 1.

Use this malicious-but-valid fixture name:

```js
const projectPath = path.join(root, 'project;touch-pwned');
assert.deepEqual(migrationCall.args, [projectPath]);
assert.equal(fs.existsSync(path.join(root, 'pwned')), false);
```

Run: `node --test tests/bulk-migration.test.js`

Expected: FAIL because apply interfaces are absent.

- [ ] **Step 5: Implement recheck, migration, validation, and circuit breaking**

`migrateCandidate` performs exactly this sequence:

```js
const rechecked = preflightCandidate(candidateFromRecord(record), context);
if (rechecked.status !== 'eligible') {
  return { ...record, status: 'changed_since_plan', reason: rechecked.reason };
}

const migration = context.runner(context.migratorPath, [record.path], {
  cwd: context.frameworkRoot,
});
const backup = /migration complete; backup: (.+)$/m.exec(migration.stdout)?.[1] || null;
if (migration.status !== 0) {
  return failedRecord(record, 'migration', migration, backup);
}

const installCheck = context.runner('node', [
  path.join(record.path, 'scripts/verify-install.js'),
  record.path,
], { cwd: record.path });
const sprintCheck = context.runner('node', [
  path.join(record.path, 'scripts/validate-sprint.js'),
  path.join(record.path, 'sprint/sprint.json'),
], { cwd: record.path });
```

Only two successful validators produce `updated`. Store bounded diagnostics via
`boundText`. `applyPlan` uses `for...of`; Promise fan-out is forbidden. Stop on
`failed` or `changed_since_plan` unless `continueOnError` is true.

- [ ] **Step 6: Write failing top-level workflow tests**

Call `main(argv, dependencies)` directly with injected `runner`, `confirm`,
`acquireLock`, `writeReports`, `now`, and signal registration. Prove:

- dry-run never acquires an apply lock or invokes the migrator;
- apply with zero eligible projects returns 2;
- interactive apply accepts only `APPLY <eligible-count>`;
- `--yes` bypasses only the prompt;
- success, failure, and interruption all finalize a report;
- interruption returns 130 and releases only the owned lock.

- [ ] **Step 7: Implement `main` and executable behavior**

`main` loads patterns, builds the plan, prints a compact status table, and
writes the plan report. Apply mode validates the source, acquires the root lock,
confirms, applies only the frozen eligible paths, finalizes reports, and releases
the lock from `finally`.

Use this executable tail:

```js
if (require.main === module) {
  main().then(
    code => process.exit(code),
    error => {
      process.stderr.write(`bulk-migrate: ${error.message}\n`);
      process.exit(error.exitCode || 1);
    }
  );
}

module.exports = { main, parseArgs, validateFrameworkSource };
```

`SIGINT` and `SIGTERM` set an interruption flag. They do not remove a lock while
a child process is running; the single `finally` block owns cleanup.

Map outcomes exactly: 0 for successful plan/apply, 1 for any migration or
post-validation failure, 2 for global preflight/lock failure or apply with zero
eligible projects, 64 for usage errors, and 130 for interruption.

- [ ] **Step 8: Run new suites and verify GREEN**

Run:

```bash
node --test tests/bulk-ignore.test.js tests/bulk-migration.test.js
```

Expected: all tests PASS and no real project is modified.

- [ ] **Step 9: Commit Task 4**

```bash
git add scripts/bulk-migrate.js scripts/lib/bulk-migration.js tests/bulk-migration.test.js
git commit -m "feat(migration): orchestrate safe bulk updates"
```

---

### Task 5: Framework Registry and Test-Runner Integration

**Files:**
- Modify: `framework.json:59-64`
- Modify: `tests/framework-consistency.sh:47-67`
- Modify: `tests/run.sh:6-13`

**Interfaces:**
- Consumes: central framework `scripts/bulk-migrate.js` and its modules.
- Produces: discoverable path metadata and mandatory suite execution in the framework source repository.

- [ ] **Step 1: Add failing registry assertions**

Add to `tests/framework-consistency.sh`:

```bash
assert_contains '"bulk_migrate": "scripts/bulk-migrate.js"' framework.json
for source in scripts/bulk-migrate.js scripts/lib/bulk-ignore.js \
  scripts/lib/bulk-migration.js scripts/lib/bulk-report.js; do
  [ -f "$source" ] || fail "Missing central bulk migration source: $source"
done
[ -x scripts/bulk-migrate.js ] || fail 'bulk-migrate.js must be executable'
```

Run: `bash tests/framework-consistency.sh`

Expected: FAIL because the path is not registered yet.

- [ ] **Step 2: Register the central entry point in `framework.json`**

Add under `paths`:

```json
"bulk_migrate": "scripts/bulk-migrate.js"
```

Do not add the tool to `install.entries`: it manages sibling repositories from
the central framework checkout and is not target-project runtime.

- [ ] **Step 3: Register both new test suites**

Add to `tests/run.sh`:

```bash
node --test "$ROOT_DIR/tests/bulk-ignore.test.js"
node --test "$ROOT_DIR/tests/bulk-migration.test.js"
```

Run:

```bash
bash tests/framework-consistency.sh
bash tests/run.sh
```

Expected: all suites PASS.

- [ ] **Step 4: Commit Task 5**

```bash
git add framework.json tests/framework-consistency.sh tests/run.sh
git commit -m "chore(migration): register bulk updater checks"
```

---

### Task 6: Documentation, Security Regression, and Final Verification

**Files:**
- Modify: `README.md:40-48`
- Modify: `GUIDE.md:104-120`
- Modify: `CHANGELOG.md:3-17`
- Modify: `tests/bulk-migration.test.js`

**Interfaces:**
- Consumes: final CLI and report statuses.
- Produces: documented plan/apply/exclude workflow and final release evidence.

- [ ] **Step 1: Add final security and idempotency tests**

Add a deterministic tree-hash helper:

```js
const crypto = require('node:crypto');
const { main } = require('../scripts/bulk-migrate');
const { buildPlan, applyPlan } = require('../scripts/lib/bulk-migration');
const { boundText, writeReports } = require('../scripts/lib/bulk-report');

function hashTree(root) {
  const hash = crypto.createHash('sha256');
  function visit(directory) {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })
      .sort((left, right) => left.name.localeCompare(right.name))) {
      const full = path.join(directory, entry.name);
      hash.update(path.relative(root, full));
      if (entry.isDirectory()) visit(full);
      else if (entry.isFile()) hash.update(fs.readFileSync(full));
    }
  }
  visit(root);
  return hash.digest('hex');
}
```

Add this dry-run test, reusing the Git runner helper from Task 2:

```js
test('dry run leaves candidates byte-identical and never calls the migrator', async () => {
  const root = tempRoot();
  const project = path.join(root, 'project;touch-pwned');
  fs.mkdirSync(path.join(project, '.git'), { recursive: true });
  frameworkMarker(project, '7.1.0');
  const before = hashTree(root);
  let migrationCalls = 0;
  const runner = (command, args, options) => {
    if (command.endsWith('migrate-project.sh')) migrationCalls += 1;
    return cleanGitResult(command, args, options);
  };
  const code = await main([root], {
    runner,
    writeReports: () => ({ jsonPath: '/state/run.json', markdownPath: '/state/run.md' }),
    now: () => new Date('2026-07-11T12:00:00Z'),
    stdout: { write() {} },
    stderr: { write() {} },
  });
  assert.equal(code, 0);
  assert.equal(migrationCalls, 0);
  assert.equal(hashTree(root), before);
  assert.equal(fs.existsSync(path.join(root, 'pwned')), false);
});
```

Add an idempotency test that applies an injected successful migration, writes
`8.0.0` to the fixture `framework.json`, rebuilds the plan, and asserts its only
project is `current`:

```js
test('a successfully updated project is current on the next plan', async () => {
  const root = tempRoot();
  const project = path.join(root, 'project');
  fs.mkdirSync(path.join(project, '.git'), { recursive: true });
  frameworkMarker(project, '7.1.0');
  const plan = buildPlan({ root, patterns: [], currentVersion: '8.0.0', runner: cleanGitResult,
    now: () => new Date('2026-07-11T12:00:00Z') });
  const runner = (command, args, options) => {
    if (command.endsWith('migrate-project.sh')) {
      frameworkMarker(project, '8.0.0');
      return { status: 0, stdout: `migration complete; backup: ${project}/.backup\n`, stderr: '' };
    }
    if (command === 'node') return { status: 0, stdout: 'valid\n', stderr: '' };
    return cleanGitResult(command, args, options);
  };
  const applied = await applyPlan(plan, {
    runner,
    migratorPath: '/framework/migrate-project.sh',
    frameworkRoot: '/framework',
    currentVersion: '8.0.0',
    continueOnError: false,
  });
  assert.equal(applied.projects[0].status, 'updated');
  const next = buildPlan({ root, patterns: [], currentVersion: '8.0.0', runner: cleanGitResult,
    now: () => new Date('2026-07-11T12:01:00Z') });
  assert.equal(next.projects[0].status, 'current');
});
```

Add the bounded, secret-free report test:

```js
test('reports bound diagnostics and omit ambient environment secrets', () => {
  const root = tempRoot();
  const reportDir = path.join(tempRoot(), 'reports');
  const secret = 'DO_NOT_SERIALIZE_THIS_VALUE';
  const previous = process.env.DG_TEST_SECRET;
  process.env.DG_TEST_SECRET = secret;
  try {
    const record = {
      schemaVersion: 1,
      mode: 'apply',
      root,
      frameworkVersion: '8.0.0',
      startedAt: '2026-07-11T12:00:00Z',
      finishedAt: '2026-07-11T12:01:00Z',
      patterns: [],
      projects: [{
        relativePath: 'broken',
        version: '7.1.0',
        afterVersion: null,
        status: 'failed',
        reason: 'migration failed',
        backup: null,
        diagnostics: boundText('x'.repeat(9000), 256),
      }],
      counts: { failed: 1 },
      exitCode: 1,
    };
    const paths = writeReports(record, reportDir);
    const json = fs.readFileSync(paths.jsonPath, 'utf8');
    assert.match(json, /truncated/);
    assert.doesNotMatch(json, new RegExp(secret));
    assert.ok(path.relative(root, paths.jsonPath).startsWith('..'));
  } finally {
    if (previous === undefined) delete process.env.DG_TEST_SECRET;
    else process.env.DG_TEST_SECRET = previous;
  }
});
```

Do not add a production test-mode flag. All fakes enter through `main` or module
dependency arguments.

Run: `node --test tests/bulk-migration.test.js`

Expected: all tests PASS.

- [ ] **Step 2: Document commands in README**

After the single-project migration example add:

```markdown
Bulk migration below a project container defaults to a read-only plan:

    node scripts/bulk-migrate.js /path/to/projects
    node scripts/bulk-migrate.js /path/to/projects --exclude "archive/**"
    node scripts/bulk-migrate.js /path/to/projects --apply

Persistent exclusions belong in `/path/to/projects/.dg-framework-ignore`.
Dirty repositories, linked worktrees, unsupported versions, and active Git
operations are reported and skipped. The updater never commits or pushes target
projects.
```

- [ ] **Step 3: Extend GUIDE and CHANGELOG**

Document in GUIDE:

- plan → inspect report → apply;
- `.dg-framework-ignore` with two concrete patterns;
- every status and skip reason;
- the default first-failure circuit breaker;
- `--continue-on-error`, external reports/locks, and manual backup recovery.

Add this CHANGELOG bullet under the next release section matching the file's
existing convention:

```markdown
- Added safe recursive bulk migration with exclusions, dirty-repository skips,
  sequential circuit breaking, external locks, and bounded audit reports.
```

- [ ] **Step 4: Run CLI and documentation sanity checks**

```bash
node scripts/bulk-migrate.js --help
node scripts/bulk-migrate.js .
rg -n 'bulk-migrate|dg-framework-ignore|continue-on-error' README.md GUIDE.md
git diff --check
```

Expected: help exits 0 with every option, dry-run makes no project changes,
documentation contains all three terms, and diff check prints nothing.

- [ ] **Step 5: Run complete framework verification**

```bash
set -euo pipefail
bash tests/run.sh
find hooks scripts tests -type f \( -name '*.js' -o -name '*.mjs' -o -name '*.cjs' \) -print0 | xargs -0 -n1 node --check
find . -type f -name '*.sh' -not -path './.git/*' -print0 | xargs -0 -n1 bash -n
find . -type f -name '*.sh' -not -path './.git/*' -print0 | xargs -0 shellcheck
git diff --check
```

Expected: all test suites pass; JavaScript syntax, Bash syntax, ShellCheck, and
diff hygiene return 0.

- [ ] **Step 6: Map acceptance criteria to evidence**

Open
`docs/superpowers/specs/2026-07-11-bulk-framework-migration-design.md` and map
acceptance criteria 1–8 to fresh command output from Steps 1–5. If any criterion
lacks evidence, add a failing regression test, implement the minimal fix, and
rerun the complete verification.

- [ ] **Step 7: Commit Task 6**

```bash
git add README.md GUIDE.md CHANGELOG.md tests/bulk-migration.test.js
git commit -m "docs: document safe bulk framework migration"
```

- [ ] **Step 8: Confirm repository state**

```bash
git status --short
git log --oneline -6
```

Expected: clean worktree and task commits in order. Do not push without explicit
user authorization.
