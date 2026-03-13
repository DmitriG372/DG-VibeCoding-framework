#!/usr/bin/env node
// DG-VibeCoding-Framework v5.0.0 — Plan-to-Sprint Hook
// PostToolUse hook: triggers /sprint-init after plan approval.
// Works with both CC (ExitPlanMode) and CX (plan-related tools).
// Injects additionalContext prompting the agent to parse the approved plan
// into sprint/sprint.json automatically.

const fs = require('fs');

// Tool names that indicate plan approval across different agents
const PLAN_EXIT_TOOLS = [
  'ExitPlanMode',      // Claude Code (CC)
  'exit_plan_mode',    // Possible Codex variant
  'exit_plan',         // Possible Codex variant
  'plan_complete',     // Possible Codex variant
];

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch { return ''; }
}

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = input ? JSON.parse(input) : {};
    const toolName = data.tool_name || '';

    // Check if this is a plan exit tool
    const isPlanExit = PLAN_EXIT_TOOLS.some(t =>
      toolName === t || toolName.toLowerCase() === t.toLowerCase()
    );

    if (!isPlanExit) {
      process.exit(0);
    }

    // Check if sprint already exists — avoid double-init
    const sprintJson = readFileSafe('sprint/sprint.json');
    let skipReason = null;

    if (sprintJson) {
      try {
        const sprint = JSON.parse(sprintJson);
        const inProgress = (sprint.features || []).filter(
          f => f.status === 'in_progress'
        );
        if (inProgress.length > 0) {
          skipReason = `Sprint ${sprint.sprint_id} is active with ${inProgress.length} feature(s) in progress`;
        }
      } catch { /* ignore parse errors, let sprint-init handle it */ }
    }

    let prompt;

    if (skipReason) {
      prompt = [
        '=== PLAN APPROVED (sprint already active) ===',
        '',
        `⚠️ ${skipReason}.`,
        'The approved plan has NOT been auto-converted to a sprint.',
        'If you want to start a new sprint from this plan, run /sprint-init manually.',
        '',
        '=== END ===',
      ].join('\n');

      process.stderr.write(`⚠️ plan-to-sprint: skipped — ${skipReason}\n`);
    } else {
      prompt = [
        '=== PLAN APPROVED — AUTO-SPRINT INIT ===',
        '',
        'MANDATORY: The user just approved a plan by exiting Plan Mode.',
        'You MUST now automatically execute /sprint-init using the approved plan.',
        '',
        'Instructions:',
        '1. Parse the plan from the conversation above — extract all features/tasks',
        '2. Run /sprint-init with these features (do NOT ask the user to repeat them)',
        '3. Ask the branch strategy question: "Kuidas tööd korraldada? main / worktree"',
        '4. Create sprint/sprint.json with all features from the plan',
        '5. Show the sprint summary',
        '',
        'The plan content is already in your conversation context — use it directly.',
        '',
        '=== END ===',
      ].join('\n');

      process.stderr.write('🚀 Plan approved — triggering auto sprint-init\n');
    }

    // Output additionalContext for the agent
    const output = {
      hookSpecificOutput: {
        additionalContext: prompt,
      },
    };

    process.stdout.write(JSON.stringify(output));
  } catch (err) {
    process.stderr.write(`⚠️ plan-to-sprint.js error: ${err.message}\n`);
  }

  process.exit(0);
});
