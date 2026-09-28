---
name: prfaq
description: Draft or improve a customer-centred PR/FAQ that frames a proposed product, service, workflow, or initiative before implementation. Use to test customer value, align stakeholders and agents, surface constraints and risks, decide whether to proceed, and define measurable outcomes without code references.
---

# Draft PR/FAQ

Create a decision-ready narrative that starts with the customer experience and works backwards. Use it before a technical design or implementation begins. Its purpose is to decide what is worth building and what must be true for it to succeed.

Do not include code references. The document must not name repositories, files, symbols, classes, modules, APIs, endpoints, schemas, commands, pull requests, test names, or implementation snippets. Describe capabilities, workflows, system boundaries, constraints, and outcomes in product language.

## Workflow

1. Read the request and the relevant project, user, market, operational, and policy context. Use authoritative external sources for material claims when available. Identify facts, assumptions, decisions, and open questions. Do not invent facts.
2. Define the primary customer or user and the painful current experience. State the change in their observable experience, not an internal activity.
3. Write the press release as if the capability launched today. Make the headline specific, lead with the customer benefit, and describe the experience in concrete terms.
4. Write external FAQs from the customer, operator, buyer, or partner perspective. Write internal FAQs from the delivery and decision perspective.
5. State the success measures, material constraints, risks, and explicit non-goals. Convert uncertainty into named questions with an owner or decision point.
6. Distinguish evidence from assumptions. Cite the source of material facts compactly. Never present a forecast as a fact.
7. Draft with [references/prfaq-template.md](references/prfaq-template.md). Remove template guidance and sections that do not affect the decision.
8. Review the narrative with the quality gate. Revise until a reader can explain the customer value, the decision requested, the major risks, and the measurable result.

Ask focused questions only when an unresolved answer changes the customer promise, scope, decision, or success measure. Otherwise state the assumption and continue.

## Document shape

- Keep the press release below one page and the whole PR/FAQ below six pages, excluding references.
- Write the press release in a few complete paragraphs. It must stand alone for its intended customer.
- Keep each FAQ answer short, direct, and evidence-backed. Prefer one question per decision or concern.
- Use plain Markdown, ordinary headings, short paragraphs, and compact tables only where they improve comprehension.
- Write for busy humans first. Cut repetition, generic praise, internal process narration, and unneeded background.
- Treat the PR/FAQ as a living decision record. Update it when a customer promise, constraint, evidence, or decision changes.

## Press release rules

- Use this heading format: `<Product or initiative> gives <customer> <specific outcome>.`
- Open with the date, owner, target customer, and launch status.
- In the first paragraph, state the customer problem, the new experience, and why it matters now.
- Explain the before-and-after customer journey with concrete observable results.
- State what makes the outcome materially better: faster, easier, safer, more reliable, less costly, or a step change. Quantify only with evidence or a labeled forecast.
- Include a representative customer quote only when it reflects supplied research or is clearly labeled illustrative.
- End with the requested decision or next customer-visible milestone. Do not use the press release to explain implementation.

## FAQ rules

Use only questions that change a decision, expose a risk, or clarify the promise. Begin with customer questions; then answer the questions a delivery leader, operator, and reviewer need answered.

### Customer questions

Cover the applicable questions:

- Who has the problem, and how often does it occur?
- What do they do today, and where does the experience fail?
- What changes for them at launch?
- Why will they choose or trust this experience?
- What does it cost them, and what value do they receive?
- What is deliberately unavailable or unchanged?
- How will they receive help, recover from a failure, or give feedback?

### Internal questions

Cover the applicable questions:

- What decision is requested now, and who owns it?
- What evidence supports demand, feasibility, and expected value?
- Which assumptions could invalidate the customer promise?
- What must be true before launch? Include policy, privacy, security, accessibility, reliability, operational readiness, partner, and legal constraints where material.
- What is the smallest customer-complete release? What is explicitly out of scope?
- What are the material risks, their early signals, and mitigations?
- How will the team measure adoption, customer benefit, quality, and unintended harm?
- What decisions remain open, who will resolve each, and by when or before which milestone?
- What would cause the team to stop, defer, narrow, or reconsider the initiative?

## Evidence and language

- Separate `Fact`, `Assumption`, `Forecast`, and `Open question` whenever the distinction matters.
- Use measurable, customer-observable language. Replace vague claims such as "seamless" or "best-in-class" with the effect, condition, and measure.
- Use active voice, present tense for current state, and future-perfect launch language only in the press release.
- Preserve defined terms. Define abbreviations on first use.
- Do not produce a technical specification, delivery plan, architecture document, or code walkthrough. Those follow only after the PR/FAQ decision.
- Do not make unsupported claims about market size, customer demand, cost, compliance, performance, or outcomes.

## Quality gate

Before delivery, verify all applicable points:

- Does the press release make a specific customer promise that an intended customer would understand without project context?
- Does the first paragraph explain who has the problem, what changes, and why the change matters now?
- Is every material claim factual, cited, or visibly labeled as an assumption or forecast?
- Do the FAQs answer the hard customer and internal questions rather than restate the press release?
- Are the decision requested, owner, scope, non-goals, success measures, and stop conditions explicit?
- Do risks cover customer harm and material launch constraints, with early signals and mitigations?
- Can a stakeholder decide whether to proceed without reading implementation details?
- Does the document contain no code references or technical implementation artifacts?
- Is the press release below one page and the entire document concise enough to read in one sitting?

## Sources informing this skill

- Amazon, [An insider look at Amazon's culture and processes](https://www.aboutamazon.com/news/workplace/an-insider-look-at-amazons-culture-and-processes): customer-first Working Backwards, short PR/FAQ narratives, fact-based iteration, and deliberate decisions not to build.
- Google, [Documentation Best Practices](https://google.github.io/styleguide/docguide/best_practices.html): concise, current, accurate documentation written for humans.
- Google, [Documentation Philosophy](https://google.github.io/styleguide/docguide/philosophy.html): radical simplicity, readable source text, and brief utilitarian documents.
