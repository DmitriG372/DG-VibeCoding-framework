# Handoff Protocol — Reference

> Level 3 reference loaded on demand from `skills/partnership/SKILL.md`.

## CC → CX (CC assigns feature to CX)

1. Ensure feature exists in `sprint/sprint.json` (use `/sprint-init` if missing)
2. Set `assigned_to: "cx"` on the target feature
3. Commit the validated sprint coordination update and create a worktree:
   ```bash
   scripts/worktree-setup.sh cx/FXXX-<slug>
   ```
4. Start CX in the worktree:
   ```bash
   cd ../<project>-wt-cx-<branch>/
   codex --sandbox workspace-write
   ```
5. CX reads `sprint/sprint.json` on session start and picks up assigned features

Use `/handoff` command to automate steps 1–4.

## CX → CC (CX returns work for review)

1. CX runs `/done` — updates feature to `in_review` in sprint.json
2. CX commits all changes to `cx/FXXX-<slug>` branch with `F<ID>` in message
3. CC reviews:
   ```bash
   /peer-review cx/FXXX-<slug>
   ```
4. CC either:
   - Merges → feature transitions to `completed`
   - Requests changes → feature returns to `in_progress` with comments

## CX Background Launch Variants

### Interactive worktree mode
```bash
cd ../<project>-wt-cx-<branch>/
codex --sandbox workspace-write
```

### Scoped to specific sprint features
```bash
codex exec --sandbox workspace-write "Read sprint/sprint.json, complete features assigned to CX"
```

### With explicit feature list
```bash
codex exec --sandbox workspace-write "Implement F003 and F004 from sprint/sprint.json"
```

## Rules

- Always update `assigned_to` via `/feature` or `/handoff` — never edit sprint.json by hand during handoff
- Include feature ID in commits: `feat(<scope>): F001 <description>`
- `sprint/sprint.md` is auto-generated — never edit manually
- `last_updated_by` must reflect the acting agent (`cc` or `cx`)
- One active feature per agent to preserve focus

## Anti-Patterns

- Handing off a feature whose branch has uncommitted changes on the sender side
- Starting CX before `sprint.json` has the feature → CX picks up wrong work
- Skipping the `in_review` state and jumping to `completed` → bypasses peer review
- Renaming branches mid-handoff → breaks `F<ID>` tracking
