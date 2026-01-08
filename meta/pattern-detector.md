# Pattern Detector

## Overview

The Pattern Detector analyzes code and implementations to identify recurring patterns, anti-patterns, and opportunities for standardization.

## Purpose

- Identify recurring code patterns
- Detect anti-patterns early
- Suggest standardization opportunities
- Feed insights to Skill Generator
- Maintain code consistency

## Detection Categories

### Positive Patterns
Patterns worth codifying into skills:
- Repeated component structures
- Common hook patterns
- API endpoint patterns
- Error handling approaches
- State management patterns

### Anti-Patterns
Patterns to flag and fix:
- Code duplication
- Inconsistent naming
- Missing error handling
- Performance issues
- Security vulnerabilities

### Opportunities
Areas for improvement:
- Abstraction candidates
- Shared utility potential
- Configuration consolidation
- Type reuse

## Detection Process

```
Scan Codebase
     ↓
Identify Repetition
     ↓
Analyze Structure
     ↓
Categorize Pattern
     ↓
Generate Report
     ↓
Suggest Actions
```

## Pattern Signatures

### Component Pattern
```typescript
// Signature: FC with props interface, styled wrapper
interface ${Name}Props {
  // props
}

export function ${Name}({ ...props }: ${Name}Props) {
  return (
    <Wrapper>
      {/* content */}
    </Wrapper>
  );
}
```

### Hook Pattern
```typescript
// Signature: use* function returning state and actions
export function use${Name}(config?: Config) {
  const [state, setState] = useState(initial);

  const action = useCallback(() => {
    // logic
  }, [deps]);

  return { state, action };
}
```

### API Pattern
```typescript
// Signature: async handler with validation and error handling
export async function ${method}(req: Request) {
  const body = await req.json();
  const validated = schema.parse(body);

  try {
    const result = await operation(validated);
    return Response.json(result);
  } catch (error) {
    return handleError(error);
  }
}
```

## Detection Metrics

| Metric | Threshold | Action |
|--------|-----------|--------|
| Duplication | 3+ occurrences | Suggest abstraction |
| Similarity | >80% similar | Flag for review |
| Complexity | High cyclomatic | Suggest refactor |
| Inconsistency | Naming variance | Suggest standardization |

## Report Format

```yaml
pattern_report:
  scan_date: <date>
  files_analyzed: <count>

  positive_patterns:
    - name: <pattern-name>
      occurrences: <count>
      files: [<file1>, <file2>]
      skill_candidate: true

  anti_patterns:
    - name: <anti-pattern>
      severity: <high|medium|low>
      occurrences: <count>
      files: [<file1>, <file2>]
      fix_suggestion: <suggestion>

  opportunities:
    - type: <abstraction|utility|config>
      description: <what could be improved>
      effort: <low|medium|high>
      impact: <low|medium|high>
```

## Integration with Agents

### Reviewer Agent
- Receives anti-pattern alerts
- Uses patterns for consistency checks

### Refactorer Agent
- Gets abstraction opportunities
- Implements pattern standardization

### Skill Generator
- Receives positive patterns
- Creates skills from detected patterns

## Usage

### Command: /analyze-patterns
```
/analyze-patterns [path]

Options:
  --type <positive|anti|all>  Pattern type to detect
  --threshold <n>             Minimum occurrences
  --output <file>             Save report to file
```

### Example Output
```
Pattern Analysis Report
=======================

✅ Positive Patterns Found: 3
  1. FormComponent (5 occurrences) → Skill candidate
  2. useAPIQuery (4 occurrences) → Skill candidate
  3. ErrorBoundary (3 occurrences) → Already standardized

⚠️ Anti-Patterns Detected: 2
  1. Inconsistent error handling (8 files) - HIGH
  2. Duplicate validation logic (4 files) - MEDIUM

💡 Opportunities: 2
  1. Extract shared Button styles → Low effort, High impact
  2. Consolidate API client config → Medium effort, High impact
```

## Continuous Monitoring

Pattern detection can run:
- On demand via command
- During code review
- Pre-commit hook
- CI/CD pipeline

---

*Part of DG-VibeCoding-Framework v2.6 Meta-Programming System*
