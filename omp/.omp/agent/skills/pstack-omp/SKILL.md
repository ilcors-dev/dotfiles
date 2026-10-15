---
name: pstack-omp
description: Maps the Cursor tools, paths, and models in pstack skills (poteto-mode, how, interrogate, arena, swarm, and others) to omp. Read it before you follow any pstack skill in omp.
hide: true
---

# pstack in omp

pstack skills are written for Cursor. Follow each skill as written, and translate each Cursor term with the tables below. When a skill and this file conflict, this file wins for tools, paths, and models. The skill wins for everything else.

`pstack-sync` rebuilds the pstack skills from upstream every day. Do not edit them: your edits disappear on the next sync. To change pstack behavior, propose an upstream pull request on `cursor/plugins` or a separate skill with a new name. A skill with the same name does not override a pstack skill.

## Subagents

A Cursor `Task` call is one item in an omp `task` call. Several `Task` calls "in one message" are one `task` call with one item per spawn. Each item sets its own `agent`, so a panel of models is one call.

omp sets the model of a subagent through its agent definition, not through a parameter. Choose the agent from three facts in the skill: `subagent_type`, `readonly`, and `model`.

| Cursor `subagent_type` | `readonly` | Claude Opus model | GPT model |
|---|---|---|---|
| `poteto-agent` | any | `poteto-agent-opus` | `poteto-agent` |
| `generalPurpose` | `false` or not set | `pstack-opus` | `pstack-gpt` |
| `generalPurpose` | `true` | `pstack-opus-ro` | `pstack-gpt-ro` |
| `comment-sicko` | any | `comment-sicko` | `comment-sicko` |

Read the model from the skill:

- A model slug that starts with `claude-` selects the Claude Opus column. A slug that starts with `grok-`, `gpt-`, or any other family selects the GPT column. omp does not use Grok.
- `auto`, `inherit-parent`, or no model selects the parent model. Use `task` for a writable spawn and `scout` for a read-only spawn. Use `poteto-agent` for `subagent_type: poteto-agent`.
- A "same prompt on a different model" second opinion uses the other column.

Reasoning level: the `pstack-opus` and `pstack-gpt` roles use `auto` thinking. When a spawn omits `effort`, omp classifies the child's first prompt and picks its level. The classifier reads only `solutionSpace`, so write it to show how open the problem is, not how large it is. Set `effort` only when the skill tells you to change the level:

| pstack instruction | `effort` |
|---|---|
| Role default (`xhigh` in a skill default or in a model slug) | Omit. `auto` decides. |
| Raise the level for the hardest or subtlest work, or `max` | `hi` |
| Lower one step, for judgment | `med` |
| Lower two or more steps, for routine work | `lo` |

`effort` maps to the lowest, middle, or highest level that the resolved model supports. `task.maxEffort` in `config.yml` caps it. Fast mode (`-fast` slugs) has no per-spawn control in omp. Ignore it.

`~/.cursor/rules/pstack-models.mdc` does not exist in omp. Each skill then uses its own default model. The upstream defaults are Claude Opus 5.5 for judgment, prose, and the hardest code, and Grok 4.7 for other code and exploration. In omp, use the GPT column wherever a skill names Grok. Panels (arena runners, architect runners, interrogate reviewers, arena cross-judge pool) use both families: one spawn per family.

`modelRoles` in `~/.omp/agent/config.yml` sets the real models. `pstack-opus` and `pstack-gpt` are the two roles. Do not change them from a skill. `/setup-pstack` is not available in omp: tell the user to edit `modelRoles` instead.

Other `Task` parameters:

| Cursor | omp |
|---|---|
| `run_in_background: true` | Default behavior. Results arrive as messages. Use `wait` only when you have no other work. |
| `environment: "cloud"` | Not available. Run the spawn locally. |
| Resume a subagent | `write agent://<id>` with the follow-up message. |
| Readonly mode strips MCP access | omp keeps MCP tools in every agent. Ignore this limit. |
| `generalPurpose` substituted for `poteto-agent` | Do not do this. `poteto-agent` and `poteto-agent-opus` load `poteto-mode` before their first turn. |

## Tools

| Cursor | omp |
|---|---|
| `AskQuestion` | `ask` |
| Todo list | `todo` |
| `/loop`, custom mode, "keep the mode on across turns" | Not available. Keep working until the todo list is complete. |
| `deslop` skill (from `cursor-team-kit`) | `unslop` skill |
| `control-ui` skill | The `browser` global in `eval` |
| `control-cli` skill | `bash` with `pty: true` for interactive programs |
| `/create-skill` | Write `SKILL.md` directly. See [Paths](#paths). |
| MCP discovery (for example in `why`) | The mounted `xd://mcp__*` tools. Read each one before first use. |

## Paths

| Cursor | omp |
|---|---|
| `~/.cursor/plugins/**/skills/<name>/SKILL.md` | `skill://<name>` |
| A path relative to a skill directory | `skill://<name>/<path>` |
| `~/.cursor/projects/<slug>/agent-transcripts/` | `~/.omp/agent/sessions/<slug>/`. `<slug>` is the workspace path relative to `$HOME`, with `-` for each `/` and a leading `-`. Each `<timestamp>_<uuid>.jsonl` file is one session. The directory with the same name holds its subagent sessions. `history://<id>` reads one agent transcript. |
| `~/.cursor/skills/`, `.cursor/skills/` (new or edited skills, for example from `automate-me`, `reflect`, `correct`) | `~/src/dotfiles/agents/.agents/skills/<name>/SKILL.md` for personal skills. `.omp/skills/<name>/SKILL.md` for project skills. |
| `~/.cursor/rules/*.mdc`, `.cursor/rules/*.mdc` | `~/.omp/agent/AGENTS.md` (in `~/src/dotfiles/omp`) or a project `AGENTS.md` |
| pstack skill text that you want to change | Tell the user. Propose an upstream pull request on `cursor/plugins`, or a separate skill with a new name in `~/src/dotfiles/agents/.agents/skills/`. |
