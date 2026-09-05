# Framework workflow audit — 2026-09-05

Scope: this repository's active contract, runtime templates, context hooks,
installation/coordination/review scripts, tests, and recent Git history. This is
not a measurement of agent speed across application repositories. Existing local
changes in the archived plan and session log were excluded.

## What the history shows

| Evidence | Observed pattern | Response |
|---|---|---|
| `d077a1b` | v9 removed per-edit checks, mandatory decomposition, and numerous coordination artifacts. | Keep the lean loop; no new mandatory plan, dependency, hook, or sprint file. |
| `5292e3e` | Follow-up corrected hooks, installer, migration, and tests after the large release. | Test observable failure cases and the installed artifact, not just file existence. |
| `7205fb8` | Worktrees lacked ignored CC hook settings; install verification also produced false positives. | Assert copied settings and the actual partner commit in the handoff test. |
| `00b1d14` | Worktree cleanup guessed a layout instead of consulting Git. | Treat repository state as authority rather than saved or inferred state. |
| `a15bfe0` | Whole-file stub scans blamed a change for existing placeholders. | Preserve added-line scanning; avoid adding broad per-edit gates. |

Inference: repeated repair commits point to boundary cases around generated files,
worktrees, and verification claims. They do not establish which model caused a
problem, nor quantify wasted time. The three newest commits were already local
and unpushed when this audit began.

## Reproduced and repaired

1. PROJECT.md extraction stopped at the heading because multiline `$` matched
   the end of that line. New tests require section bodies, nested headings, and
   the final section to survive.
2. Recovery accepted another session's snapshot and presented saved Git state as
   current. It now requires a matching session ID, labels saved context, and reads
   Git live. Corrupt snapshots use the same live fallback.
3. PreCompact rewrote the narrative memory timestamp without updating the memory.
   It now leaves agent-authored notes untouched. Recovery points to existing notes
   when needed instead of automatically injecting potentially unrelated narrative.
4. Handoff reused an old branch without the new coordination commit, or committed
   before detecting an occupied directory. Both predictable conflicts now fail
   before staging; successful handoff creates a new branch at the new commit.
5. The contract forbade rechecks even after changes, demanded a separate sprint
   completion commit, and told agents to stop on any failed step. It now ties
   checks to their inputs, keeps related completion metadata in one commit, and
   requires diagnosis and honest blocked reporting.
6. PROJECT.md's template duplicated a task board and assumed npm commands. It now
   asks for real project commands and leaves coordination to the optional sprint.

## Limits and follow-up

- Test coverage here exercises hooks directly and installs into temporary projects.
  Identical CC/CX hook JSON is configuration parity, not proof of runtime support.
  A real lifecycle smoke check in both installed clients remains necessary before
  claiming equivalent hook enforcement. The shared instructions remain the baseline.
- Secret and completion hooks are best-effort guardrails. Shell/tool aliases and
  indirect operations are not a security boundary; OS permissions and Git/CI
  checks remain necessary. This update does not expand those matchers speculatively.
- No application projects were migrated. Review project-specific contract customizations
  before distributing this update through setup or migration.
- No speedup percentage is claimed. The measurable workflow simplification is one
  fewer required commit when completing a sprint-listed task.

## Verification evidence

- Before the context fix: `node --test tests/hooks.test.js` — 10 passed, 3 failed;
  failures reproduced missing section bodies, another session's rules, and stale branch state.
- After the context fix: the same command — 13 passed, 0 failed.
- Before the handoff fix: `bash tests/worktree-coordination.sh` —
  `FAIL: handoff accepted an existing branch with stale assignment`.
- After the handoff fix: the same command — `worktree-coordination: ok`.
- `bash tests/run.sh` — `framework-tests: all suites passed` (all ten suites).
- `shellcheck scripts/handoff-worktree.sh tests/worktree-coordination.sh` — exit 0.
- After the final contract wording adjustment: `node --test tests/parity.test.js` —
  9 passed, 0 failed. `git diff --cached --check` — exit 0.
- Independent review was attempted with `scripts/headless-review.sh --tool codex
  --mode quick --staged`. The sandbox attempt failed to initialize the local
  app-server. An authorized retry started but produced no review after about five
  minutes and warned that model metadata was unavailable; it was terminated.
  No independent review verdict is claimed.
