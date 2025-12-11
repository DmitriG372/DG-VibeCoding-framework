# Command: /analyze-patterns

## Purpose

Analyzes the codebase to detect recurring patterns, anti-patterns, and standardization opportunities. Feeds into skill generation and code quality improvement.

## Usage

```
/analyze-patterns [path] [options]
```

## When to Use

- Regular codebase health checks
- Before major refactoring
- After implementing multiple features
- To identify skill candidates
- During code reviews

## Options

| Option | Description | Default |
|--------|-------------|---------|
| --type <type> | positive\|anti\|opportunities\|all | all |
| --threshold <n> | Minimum occurrences | 3 |
| --output <file> | Save report to file | - |
| --format <fmt> | yaml\|markdown\|json | markdown |

## Analysis Types

### Positive Patterns
Successful patterns worth standardizing:
- Component structures
- Hook patterns
- API patterns
- Error handling
- State management

### Anti-Patterns
Issues to address:
- Code duplication
- Inconsistent naming
- Missing error handling
- Security issues
- Performance problems

### Opportunities
Improvement suggestions:
- Abstraction candidates
- Utility extraction
- Configuration consolidation
- Type reuse

## Workflow

```
/analyze-patterns src/
        ↓
   Scan Directory
        ↓
   Parse Files
        ↓
   Detect Patterns
        ↓
   Categorize Findings
        ↓
   Generate Report
        ↓
   Suggest Actions
```

## Output Format

```markdown
# Pattern Analysis Report

📅 Date: <date>
📁 Scope: <path>
📊 Files Analyzed: <count>

## ✅ Positive Patterns

### Pattern: <name>
- **Occurrences:** <count>
- **Files:** <list>
- **Skill Candidate:** Yes/No
- **Structure:**
  ```
  <pattern structure>
  ```

## ⚠️ Anti-Patterns

### Anti-Pattern: <name>
- **Severity:** HIGH/MEDIUM/LOW
- **Occurrences:** <count>
- **Files:** <list>
- **Issue:** <description>
- **Fix:** <suggestion>

## 💡 Opportunities

### Opportunity: <name>
- **Type:** Abstraction/Utility/Config
- **Impact:** HIGH/MEDIUM/LOW
- **Effort:** HIGH/MEDIUM/LOW
- **Description:** <what could be improved>

## 📋 Recommended Actions

1. [Priority] <action> - <reason>
2. [Priority] <action> - <reason>
```

## Examples

### Example 1: Full Analysis
```
/analyze-patterns src/

Pattern Analysis Report
=======================

📅 Date: 2025-11-29
📁 Scope: src/
📊 Files Analyzed: 47

## ✅ Positive Patterns (3)

### 1. FormComponent
- Occurrences: 5
- Files: ContactForm, LoginForm, SignupForm, ProfileForm, SearchForm
- Skill Candidate: ✓ Yes
- Structure: React Hook Form + Zod + Error Display

### 2. useAPIQuery
- Occurrences: 4
- Files: useUsers, useProducts, usePosts, useComments
- Skill Candidate: ✓ Yes

### 3. ErrorBoundary
- Occurrences: 3
- Already standardized ✓

## ⚠️ Anti-Patterns (2)

### 1. Inconsistent Error Handling
- Severity: HIGH
- Occurrences: 8 files
- Issue: Mix of try/catch and .catch()
- Fix: Standardize on try/catch with Error type

### 2. Duplicate Validation Logic
- Severity: MEDIUM
- Occurrences: 4 files
- Issue: Same email validation in multiple places
- Fix: Extract to shared validation utility

## 💡 Opportunities (2)

### 1. Extract Button Styles
- Impact: HIGH, Effort: LOW
- 6 components with similar button styling

### 2. Consolidate API Config
- Impact: HIGH, Effort: MEDIUM
- Base URL and headers repeated in 5 files

## 📋 Recommended Actions

1. [HIGH] Generate skill for FormComponent pattern
2. [HIGH] Fix inconsistent error handling
3. [MED] Extract shared validation utilities
4. [LOW] Consolidate API configuration
```

### Example 2: Anti-Pattern Focus
```
/analyze-patterns src/ --type anti

Anti-Pattern Analysis
=====================

⚠️ Found 5 anti-patterns:

1. [HIGH] N+1 Query - src/api/users.ts:45
2. [HIGH] Unhandled Promise - src/utils/fetch.ts:12
3. [MED] Magic Numbers - src/components/Grid.tsx:8
4. [MED] Prop Drilling - src/pages/Dashboard.tsx
5. [LOW] Console.log Left - src/hooks/useAuth.ts:23
```

## Integration

Results can feed into:
- `/generate-skill` - For positive patterns
- `refactorer` agent - For anti-patterns
- `reviewer` agent - For code review context

---

*Part of DG-SuperVibe-Framework v2.0 Meta-Programming System*
