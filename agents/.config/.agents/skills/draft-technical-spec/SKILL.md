---
name: draft-technical-spec
description: Draft or improve concise technical design specifications that let an LLM and a human study a problem and implement a solution. Use for HLD, LLD, implementation proposals, design decisions, API or data-model changes, and technical plans that must state scope, constraints, alternatives, risks, and verification in ASD-STE100-style English within six pages.
---

# Draft Technical Spec

Produce a decision-ready specification. Make it short enough to read in one sitting and complete enough to implement without rediscovery.

## Workflow

1. Start below the title with two lines: `Draft date: YYYY-MM-DD` and `Current status: <status>`. Use the current date. Set `<status>` to exactly one of `implemented`, `draft`, or `ready-for-implementation`.
2. Read the issue, existing specification, repository context, and primary external documentation. Identify facts, assumptions, and open questions. Do not invent facts.
3. State the problem as a present-tense cause and effect. Define a measurable goal and explicit non-goals.
4. Extract the design constraints that change the solution. Link each material claim to code, a test, a ticket, or an authoritative source.
5. Evaluate exactly three credible approaches against a 1-5 decision matrix. Select the winner only after the comparison. Then put it first as `Approach A - <name> (recommended)`, followed by `Approach B - <name>` and `Approach C - <name>`.
6. Write the document with the template in [references/spec-template.md](references/spec-template.md). Remove sections that do not affect the decision.
7. Review the document against the quality gate before delivery.

Ask focused questions only when an unresolved choice changes the proposed solution. Otherwise, state the assumption and continue.

## Content rules

- Put the decision and outcome in the summary. Do not make readers infer them.
- Describe current behaviour before proposed behaviour when the difference matters.
- Outline the approaches and make the decision before you describe the proposed design.
- Define invariants and fallback behaviour. Use a decision matrix for three or more important cases.
- Compare all three approaches in one decision matrix. Choose three to five metrics that materially affect the decision. Score each metric from 1 to 5, where 5 is best. Support each score with evidence or an explicit assumption. Do not preselect a winner.
- Highlight the chosen Approach A column in bold in the decision matrix. Put approval and rejection statements in a Decision section after the matrix, not in the approach descriptions.
- Give each approach a compact pros-and-cons table. Use three rows by default. Do not use more than five rows.
- Include contracts for changed APIs, data models, events, or background jobs. State ownership, inputs, outputs, validation, and idempotency as applicable.
- Add an Error Handling section when the design has material validation errors, external dependencies, asynchronous work, partial completion, or recovery paths. Omit it when none apply.
- Include one diagram only when a flow has three or more dependent steps. Prefer a small sequence or flow diagram.
- Keep implementation detail at the boundary of a decision. Link to code locations instead of copying code.
- Put testable acceptance criteria in the verification section. State rollout, telemetry, and recovery only when risk requires them.
- Keep references compact: source identifier, location, and the fact it supports.

## Six-page budget

Target 1,400–2,200 words excluding diagrams, tables, and references. Treat 2,500 words as a hard review threshold. Use this default allocation:

| Section | Target |
| --- | ---: |
| Summary and scope | 250 words |
| Current state and constraints | 450 words |
| Proposed design and contracts | 750 words |
| Alternatives and decision | 350 words |
| Delivery and verification | 300 words |

Move inventories, exhaustive API estimates, and research notes to linked documents. Keep only information that changes the decision or implementation.

## ASD-STE100-style writing

Write in clear controlled English. Use the official ASD-STE100 dictionary or checker when the user provides one.

- Use active voice and present tense for descriptions.
- Keep one topic in each descriptive sentence. Keep descriptive sentences to 25 words or fewer.
- Write implementation actions in the imperative form. Keep each procedural sentence to 20 words or fewer. Give one action per sentence unless the actions occur together.
- Use a stable technical term for one concept. Define abbreviations on first use.
- Prefer concrete verbs and nouns. Avoid idioms, phrasal verbs, vague qualifiers, and marketing language.
- Do not use contractions. Use vertical lists to separate conditions, options, and steps.
- Preserve code identifiers, API values, and quoted product text exactly. Treat them as technical terms, not prose to simplify.

## Quality gate

Before delivery, verify that the specification answers all applicable questions:

- Does the line below the title give the current draft date and one permitted status?
- What fails or costs time today? Who is affected?
- What outcome will prove success?
- What is in scope, and what is deliberately excluded?
- Which facts or constraints force the design?
- What changes in data, APIs, workflows, permissions, and side effects?
- When applicable, does Error Handling state failure results, retries, recovery, and idempotency?
- Does the document evaluate exactly three approaches? Does a three-to-five-metric 1-5 decision matrix support the chosen `Approach A - <name> (recommended)`?
- Does the matrix bold the chosen Approach A column? Do approval and rejection statements appear after the matrix?
- Does each approach have a pros-and-cons table with three to five concise rows?
- Which alternative was rejected, and why?
- What tests and rollout checks prove the change?

Remove repeated decisions, unsupported claims, speculative implementation detail, and generic background. Finish with a concise references list.

## General rules

- Do not state the writing style used anywhere. Apply it without naming it.
