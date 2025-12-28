---
description: Create detailed specification through multi-agent pipeline
---

# /spec

Loo detailne tehniline spetsifikatsioon läbi mitme-agendi pipeline'i.

Inspireeritud: Auto-Claude Spec Pipeline (Gatherer → Researcher → Writer → Critic).

## Parameetrid

```
/spec [feature_name] [complexity]
```

- `feature_name` - funktsionaalsuse nimi
- `complexity` - SIMPLE | STANDARD | COMPLEX (vaikimisi: STANDARD)

## Pipeline Phases

### SIMPLE (3 faasi) - Väikesed muudatused
```
Discovery → Quick Spec → Validate
```

### STANDARD (5 faasi) - Tavaline feature
```
Discovery → Requirements → Context → Spec Creation → Validate
```

### COMPLEX (7 faasi) - Suuremad süsteemid
```
Discovery → Requirements → Research → Context → Spec Creation → Self-Critique → Validate
```

## Instructions

1. **Determine complexity:**
   - SIMPLE: < 3 files, clear requirements
   - STANDARD: 3-10 files, some unknowns
   - COMPLEX: > 10 files, architectural decisions

2. **Run appropriate pipeline:**

### Phase 1: Discovery (all)
```yaml
Agent: planner
Action: Understand user intent
Output:
  - Core problem statement
  - Initial scope estimate
  - Key questions to ask
```

### Phase 2: Requirements Gathering (STANDARD+)
```yaml
Agent: planner
Action: Collect detailed requirements
Questions:
  - What is the expected behavior?
  - What are the edge cases?
  - What are the constraints?
  - Who are the users?
Output:
  - Functional requirements list
  - Non-functional requirements
  - Acceptance criteria
```

### Phase 3: Research (COMPLEX only)
```yaml
Agent: research-specialist
Action: Investigate existing solutions
Tasks:
  - Search codebase for patterns
  - Check external documentation
  - Identify reusable components
Output:
  - Existing pattern analysis
  - Recommended approach
  - Risk assessment
```

### Phase 4: Context Analysis (STANDARD+)
```yaml
Agent: architect
Action: Analyze project context
Read:
  - PROJECT.md
  - Relevant existing code
  - Related tests
Output:
  - Integration points
  - Affected components
  - Dependencies
```

### Phase 5: Spec Creation (all)
```yaml
Agent: documenter
Action: Write detailed specification
Format:
  ## [Feature Name] Specification

  ### Overview
  [What this feature does]

  ### Requirements
  #### Functional
  - FR1: [requirement]
  - FR2: [requirement]

  #### Non-Functional
  - NFR1: [performance, security, etc.]

  ### Technical Design
  #### Architecture
  [How it fits into the system]

  #### Data Model
  [New/modified data structures]

  #### API/Interface
  [New endpoints or interfaces]

  #### Components
  | Component | Purpose | New/Modified |
  |-----------|---------|--------------|
  | X | Y | New |

  ### Implementation Plan
  1. [Step 1]
  2. [Step 2]

  ### Testing Strategy
  - Unit tests: [what to test]
  - Integration tests: [what to test]
  - Edge cases: [list]

  ### Acceptance Criteria
  - [ ] AC1: [criterion]
  - [ ] AC2: [criterion]

  ### Risks & Mitigations
  | Risk | Impact | Mitigation |
  |------|--------|------------|
  | X | HIGH | Y |

  ### Open Questions
  - [Any unresolved items]
```

### Phase 6: Self-Critique (COMPLEX only)
```yaml
Agent: reviewer
Action: Challenge the specification
Checks:
  - Is scope creep happening?
  - Are there simpler alternatives?
  - What's missing?
  - Is it testable?
Output:
  - Critique report
  - Suggested improvements
  - Final recommendations
```

### Phase 7: Validate (all)
```yaml
Agent: planner
Action: Final validation
Checks:
  - Does spec match original request?
  - Is it complete enough to implement?
  - Are acceptance criteria measurable?
Output:
  - Validation status
  - Spec file location
```

3. **Save specification:**
   ```
   Location: specs/{feature_name}_spec.md
   ```

4. **Output summary:**

```yaml
## Spec Pipeline Complete

**Feature:** [name]
**Complexity:** SIMPLE | STANDARD | COMPLEX
**Phases Completed:** X / Y

### Specification Summary
- Requirements: X functional, Y non-functional
- Components: X new, Y modified
- Estimated scope: [files/LOC estimate]

### Deliverables
- Spec file: `specs/{feature_name}_spec.md`
- Implementation plan: X steps

### Next Steps
1. Review spec with stakeholders (if needed)
2. Run `/sprint-init` to begin implementation
3. Or `/implement specs/{feature_name}_spec.md`
```

## Example

Input: `/spec user-authentication COMPLEX`

Output:
```yaml
## Spec Pipeline Complete

**Feature:** user-authentication
**Complexity:** COMPLEX
**Phases Completed:** 7 / 7

### Specification Summary
- Requirements: 8 functional, 5 non-functional
- Components: 4 new, 2 modified
- Estimated scope: 12 files, ~800 LOC

### Deliverables
- Spec file: `specs/user-authentication_spec.md`
- Implementation plan: 6 steps

### Next Steps
1. Review spec for security considerations
2. Run `/sprint-init specs/user-authentication_spec.md`
```

## Integration

- Works with `/sprint-init` for implementation
- Specs can be used with `/implement [spec_file]`
- `/review` can validate specs before implementation

---

*Part of DG-VibeCoding-Framework v2.5*
*Inspired by Auto-Claude Spec Pipeline pattern*
