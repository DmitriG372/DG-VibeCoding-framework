#!/usr/bin/env node

const fs = require('node:fs');

function parseReview(text) {
  let candidate = text.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  let parsed = JSON.parse(candidate);
  if (parsed && typeof parsed === 'object' && typeof parsed.result === 'string') {
    candidate = parsed.result.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
    parsed = JSON.parse(candidate);
  }
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error('review must be a JSON object');
  for (const key of ['score', 'verdict', 'issues', 'summary']) {
    if (!(key in parsed)) throw new Error(`review missing ${key}`);
  }
  if (!Array.isArray(parsed.issues)) throw new Error('review issues must be an array');
  return parsed;
}

const [inputPath, outputPath, tool, target, mode, truncated] = process.argv.slice(2);
if (!inputPath || !outputPath) {
  process.stderr.write('Usage: normalize-review.js <input> <output> <tool> <target> <mode> <truncated>\n');
  process.exit(64);
}
try {
  const review = parseReview(fs.readFileSync(inputPath, 'utf8'));
  review.tool = tool;
  review.target = review.target || target;
  review.mode = review.mode || mode;
  if (truncated === 'true') review.warning = 'Review input was truncated to the configured byte limit';
  const temporary = `${outputPath}.tmp-${process.pid}`;
  fs.writeFileSync(temporary, `${JSON.stringify(review, null, 2)}\n`);
  fs.renameSync(temporary, outputPath);
} catch (error) {
  process.stderr.write(`normalize-review: ${error.message}\n`);
  process.exit(1);
}

module.exports = { parseReview };
