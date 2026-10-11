---
name: write-docs
description: Write, edit, or review documents that people read, such as design documents, specifications, narratives, PR/FAQs, pull request descriptions, READMEs, runbooks, postmortems, status updates, and emails. Use when an agent drafts or critiques prose for teammates. Applies reader-first structure, evidence-backed claims, and ASD-STE100 Simplified Technical English.
---

# Write Docs

A document lets readers think and decide without the author in the room. Write for the reader, not for yourself. Make the document as short as possible and as long as necessary.

Apply these rules to the prose of every document. When a document type has its own skill, that skill owns the structure and these rules own the writing. For example, `draft-technical-spec` owns specification structure and `prfaq` owns PR/FAQ structure. When a rule here conflicts with a rule in the document-type skill, the document-type skill wins.

## Workflow

1. **Define the purpose.** Write one sentence that states what the reader must do after reading: decide, approve, give feedback, or learn. If you cannot write this sentence, ask the user before you draft.
2. **Analyze the reader.** Identify who reads the document, what they already know, and where they will disagree. Use this analysis to decide how much context to give.
3. **Gather evidence before you write.** Read the code, tickets, data, and earlier documents on the topic. Separate facts from assumptions. Do not invent numbers, dates, names, or results.
4. **Outline.** Write the headings and one topic sentence for each section. Put a placeholder such as `[X: p95 latency, source needed]` where data is missing. Check that the outline leads to the conclusion.
5. **Draft.** Apply the structure, format, and evidence rules below. Apply the sentence rules in [Plain English rules](#plain-english-rules).
6. **Edit.** Use the passes in [Edit](#edit). Remove each sentence that does not help the reader decide or act.
7. **Report.** In the chat, list the open placeholders, the assumptions, and the questions that the user must answer.

Put most of the effort into preparation (steps 1–4) and editing (step 6). The first draft is the short step.

## Structure

- Put the bottom line first. The first paragraph states the purpose, the request, and the recommendation. A reader must know the purpose within ten seconds.
- Give the opening paragraph the most care. Readers judge the whole document by it.
- State the scope early. Say what the document covers and what it does not cover.
- Start each section with a sentence that states its point. The first sentences of all sections, read in order, must tell the full argument.
- Make each section complete. Make each section build on the previous one. The conclusion must follow from the evidence in the document.
- Make a recommendation when the document asks for a decision. Give the reasons in the same place: "Do X because of Y and Z."
- Show the alternatives that you considered and the reasons that you rejected them. Name the topics that are still in dispute.
- End with next steps. Give each step an owner and a date or a milestone.
- List the ten questions that a skeptical reader will ask. Answer the important questions in the text. Put the others in a supplemental FAQ, in order of importance.
- Use appendices and supplemental FAQs only for supporting detail. The main text must make its argument without them. Do not put key information only in them. This rule does not apply when the FAQ is part of the main document, as in a PR/FAQ.
- When the text refers to an appendix, make sure that the appendix exists and contains the information.
- Leave out topics that do not serve the purpose. Each extra topic invites a tangent.

Keep a narrative to six pages or fewer (about 3,000 words), excluding appendices. A longer document usually says too much.

## Format

- Write reasoning as paragraphs, not as bullet fragments. Full sentences force complete thoughts.
- Use a vertical list only for real lists: steps, options, conditions, or items. Put the most important item first.
- Use descriptive headings. The headings alone must show the structure of the argument.
- Put sets of numbers in a table. Add one sentence that states what the table shows.
- Use a chart only when it shows a trend better than a table or a sentence. Give the chart a title, axis labels, units, and a legend. Do not use pie charts or 3D charts.
- Use a diagram only when it carries more meaning than words in the same space.
- Do not use color as the only signal. Write the status as a word, for example "at risk".
- Give the document a title and a date.
- Spell out each acronym at first use. Use as few acronyms as possible.

## Evidence

- Support each claim with data or a source. Otherwise, label it as `Assumption`, `Estimate`, or `Open question`.
- Be specific. Write "On 2026-03-04, 7% of checkout requests returned HTTP 502 from 14:10 to 15:25 UTC", not "Some errors occurred in early March".
- Give an absolute baseline with each relative metric: "Build time dropped 35%, from 20 minutes to 13 minutes."
- Back each comparison with numbers: "Option A is cheaper (2 engineer-days, against 6 for option B)."
- Explain each metric that the reader does not use every day.
- Use estimates only for the future. Say how you made each estimate.
- Include data that argues against your position. State the gaps in your data before a reader finds them.
- Ask "so what?" for each number. Remove data that does not change the decision. State the conclusion that the data supports; do not leave the analysis to the reader.

## Word choice

Replace vague words with data, or remove them.

| Problem | Examples | Fix |
| --- | --- | --- |
| Weasel words | significant, many, few, often, soon, some, most, better, faster, should, might | Give the number, the date, or a statement of intent. |
| Indirect language | I believe, we think, in general, we would like to | State the fact directly. |
| Filler qualifiers | actually, really, basically, very, quite, somewhat, kind of | Delete them. |
| Redundant pairs | each and every, full and complete, first and foremost | Keep one word. |
| Wordy phrases | due to the fact that, in the event that, for the purpose of, it is necessary that | Write because, if, to, must. |
| Announcements | I want to point out that, this section describes | Delete them and make the point. |
| Adjectives and adverbs | quickly, huge, robust, seamless, best-in-class | Give the measured effect. |
| Negative constructions | did not succeed, is not good, does not conclusively show | Write failed, is poor, is inconclusive. |

Call things by their names. If it is a defect, write "defect". If a value increases, write "increases". Use "not" for contrast, for example "a decision, not a status update". Do not use "not" to avoid a direct statement.

## Edit

Edit in four passes. Each pass has one goal.

1. **Content.** Read the document as the most hostile stakeholder. For each section, ask: Do I believe this? What argument or data is missing? Where can a reader disagree?
2. **Flow.** Read only the first sentence of each section and paragraph. These sentences must tell the full story in order.
3. **Sentences.** Check each sentence against [Plain English rules](#plain-english-rules) and the word-choice table. Split each sentence that is longer than the limit.
4. **Mechanics.** Check spelling, grammar, terms, acronyms, links, appendix references, and numbers that appear more than once.

Before delivery, answer the quality gate:

- **Clear:** Can a reader state the purpose and the request after the first paragraph? Does the document recommend a solution and give next steps?
- **Evidence-based:** Does data support each claim? Does the document show counter-evidence, alternatives, and open issues?
- **Tested:** Does the document answer the questions that its readers will ask? Is it free of contradictions?
- **Concise:** Can you delete a sentence, paragraph, or section without loss? If yes, delete it.

## Review a document

When the user asks for a review, give feedback. Do not rewrite the document unless the user asks.

1. Find the feedback that the author needs. If the request does not say, review all three areas below.
2. Sort the findings into three areas:
   - **Clarity of thought:** the purpose and the request in the first paragraph, the problem in one sentence, the solution and its open questions.
   - **Structure:** descriptive headings, an order from purpose to background to recommendation to next steps, and no long text without headings.
   - **Style:** data and specific examples, weasel words, sentence length, active voice, and typos. Style problems usually appear in the first two paragraphs.
3. Start with one specific strength.
4. Report the top three patterns, not every error. For each pattern, quote one example, explain the effect on the reader, and suggest a fix.

## Rules for agents

- Do not name the writing style or these rules in the document. Apply the rules without comment.
- Do not fill gaps with plausible content. Use a placeholder and report it.
- Follow the template or house style of the repository when it conflicts with the format rules here. The sentence and evidence rules still apply.

## Plain English rules

These rules follow ASD-STE100 Simplified Technical English. Apply them to responses and to documents. Use the official ASD-STE100 dictionary or checker when the user provides one.

- Make instructions as clear and specific as possible.
- Do not write multi-word nouns that have more than three words.
- Do not use auxiliary verbs to make complex verb constructions. Write "the job fails", not "the job would have been failing".
- Use the active voice instead of the passive voice as much as possible. Say who does what. If you can add "by zombies" after the verb, the sentence is passive.
- Use the present tense for descriptions, unless a document-type skill requires another tense. Write instructions in the imperative form.
- Write short sentences: no more than 20 words in instructions (procedures) and 25 words in descriptive text.
- Do not omit parts of the sentence, such as the verb, the subject, or the article, to make the text shorter.
- Use vertical lists for complex text.
- Write one instruction per sentence.
- Write only one topic per paragraph. Start the paragraph with the sentence that states the topic.
- Do not write more than six sentences in each paragraph.
- Use one term for one concept. Do not change the term for variety.
- Use concrete verbs and nouns. Do not use idioms, phrasal verbs, or contractions.
- Keep code identifiers, commands, API values, and quoted text exactly as they are. These rules do not apply to them.
