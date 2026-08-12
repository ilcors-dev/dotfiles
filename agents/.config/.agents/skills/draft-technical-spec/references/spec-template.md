# Concise Technical Specification

Draft date: YYYY-MM-DD
Current status: draft

Use only sections that affect the decision. Keep the document within the six-page budget.

## Summary

State the problem, the proposed decision, and the expected result in three to five sentences.

## Scope

State the included work, excluded work, and non-goals. Define the owner of each system boundary.

## Current State and Constraints

Describe the current flow and the evidence that constrains the design. Include only findings that change the decision.

Use a small comparison table or diagram when it makes the before/after state clearer.

## Alternatives

Evaluate exactly three approaches. Build the decision matrix before you select a winner. Then put the selected approach first. Give each approach a compact pros-and-cons table with three rows by default and no more than five.

### Approach A - <name> (recommended)

State the design and material trade-offs.

| Pros | Cons |
| --- | --- |
| | |
| | |
| | |

### Approach B - <name>

State the design and material trade-offs.

| Pros | Cons |
| --- | --- |
| | |
| | |
| | |

### Approach C - <name>

State the design and material trade-offs.

| Pros | Cons |
| --- | --- |
| | |
| | |
| | |

Use a decision matrix with three to five metrics that change the decision. For example, use product fit, delivery effort, operational risk, runtime cost, or reliability when applicable. Use only relevant metrics. Score each approach from 1 to 5, where 5 is best. Give each score a concise reason, fact, or explicit assumption. Do not assign scores without support.

| Metric | **Approach A - <name> (recommended)** | Approach B - <name> | Approach C - <name> |
| --- | --- | --- | --- |
| <metric 1> | **<1-5> - <reason>** | <1-5> - <reason> | <1-5> - <reason> |
| <metric 2> | **<1-5> - <reason>** | <1-5> - <reason> | <1-5> - <reason> |
| <metric 3> | **<1-5> - <reason>** | <1-5> - <reason> | <1-5> - <reason> |
| Total | **<sum>** | <sum> | <sum> |

Use the total as a summary, not a substitute for judgment. Explain a decision that does not select the highest total.

## Decision

State the decision after the matrix.

- **Approved:** Approach A - <name>
- **Rejected:** Approach B - <name>
- **Rejected:** Approach C - <name>

State why the matrix and material trade-offs support the approved approach.

## Proposed Design

Describe the chosen Approach A in execution order. State contracts for each changed boundary:

- Inputs and outputs
- Data ownership and persistence
- Validation and authorization
- Side effects and ordering
- Idempotency

Add a decision matrix for material fallback paths or edge cases.

## Error Handling (if applicable)

Include this section only when the design has material validation errors, external dependencies, asynchronous work, partial completion, or recovery paths.

For each material failure case, state the trigger, visible result, retry or recovery behaviour, and idempotency requirement. Omit non-material failures.

## Delivery and Verification

State migration or rollout steps only when needed. List observable success signals and focused tests that prove the requirements.

## References

List primary sources as compact identifiers. Include repository paths, tests, APIs, tickets, and external documentation.
