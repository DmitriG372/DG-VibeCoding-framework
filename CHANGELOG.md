# Changelog

## 9.0.0 — 2026-07-27

A subtraction release. v8 required nine non-code artifacts to finish a 60-line
fix, denied every edit until the active task carried five written steps, and
spawned seven node processes per edit. None of its 12 commands, 8 skills,
6 subagents or 7 rule files had any loading path in Codex.

**Breaking**

- Made `AGENTS.md` the single shared contract and `CLAUDE.md` an `@AGENTS.md`
  import plus a short Claude-only section, so both agents load identical behaviour.
- Replaced the sprint-v3 contract with schema v4: five fields per task, unknown
  keys ignored. `sprint/sprint.json` is no longer installed and is never a
  precondition for writing code.
- Replaced `migrate-v7-to-v8.sh` with `migrate-to-v9.sh`, which removes retired
  machinery by name, strips its wiring from both settings files, refuses to run
  inside a git worktree, and archives a non-conforming sprint file instead of
  converting it.

**Removed**

- All 7 `.claude/rules/` files, `EXECUTION_PROTOCOL.md`, and `HOOKS.md` —
  455 lines auto-loaded for Claude every session, invisible to Codex, and
  mutually contradictory. The load-bearing constraints moved into `AGENTS.md`.
- The per-step user gate, the 5–10 step decomposition mandate, and the
  `>50 LOC → must delegate` threshold. Together they made autonomy unreachable:
  every real task became a 3+ step plan that had to stop after every step.
- 10 of 15 hooks: `decomposition-guard`, `type-check`, `auto-format`,
  `scope-guard`, `sprint-sync`, `plan-to-sprint`, `context-monitor`,
  `usage-tracker`, `test-dir-protection`, `test-output-filter`. No hook now runs
  on an edit; typecheck and formatting belong in `make pre-commit` or CI.
- All 8 skills, 4 of 6 subagents, and 9 of 12 commands — `done`, `handoff` and
  `review` survived, and `/sprint` is new. The framework ships no skills and no
  rules at all, because Codex can read neither.
- `core/PROJECT.md` and six stale v8 templates (`CLAUDE.md.template`,
  `SNAPSHOT.md.template`, `PROJECT.md.template`, and the agent/skill/command
  scaffolds), plus the orphaned `migrate-sprint-v3.js` and `migrate-skills.sh`.
- The generated `sprint/sprint.md`, session logs, and SNAPSHOT rituals.

**Fixed**

- `block-env` matched lowercased substrings, so it hard-blocked ordinary source
  files such as `src/auth/password-reset.ts` and `docs/api_key_rotation.md`.
  Matching is now anchored to the basename and whole path segments, and
  `.env.example` stays readable.
- Three documents described `test-dir-protection` as a hard block after v8.0.0
  had already softened it to an advisory.

**Added**

- `tests/parity.test.js`: fails if the two runtimes wire different hook sets, if
  any hook is wired on an edit, if `CLAUDE.md` stops importing the contract, if
  the contract exceeds 150 lines, or if a command points at a missing section.
  CC/CX parity is now enforced mechanically rather than by discipline.

## 8.0.0 — 2026-07-11

- Added a strict sprint-v3 contract and dependency-free validator.
- Added Codex project hooks and cross-runtime hook payload normalization.
- Made setup manifest-driven, verifiable, and safe against accidental overwrite.
- Made backups collision-proof and rejected invalid worktree branch names early.
- Replaced destructive migration with preservation-first merge and rollback.
- Made parallel handoff worktree-only with committed coordination state.
- Removed shell interpolation from formatting and headless review paths.
- Added Codex JSONL review parsing and secret-path filtering.
- Changed test-file protection from a hard block to a failed-test advisory.
- Kept team guidance and sprint state tracked in every repository-access mode.
- Expanded deterministic unit, integration, security, and artifact tests.

Release licensing remains an explicit repository-owner decision.
