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

omp uses only its bundled agents and user-tagged model agents. omp sets the model of a subagent through its agent, not through a parameter. Choose the agent from three facts in the skill: `subagent_type`, `readonly`, and `model`.

| Cursor `subagent_type` | `readonly` | omp agent | First line of the spawn's `task` |
|---|---|---|---|
| `poteto-agent` | any | `task` | "Read `skill://pstack-omp` and `skill://poteto-mode` in full before any work. You are a delegate: do not run a playbook." |
| `generalPurpose` | `false` or not set | `task` | none |
| `generalPurpose` | `true` | `reviewer` for review, judgment, or a second family; `scout` for cheap exploration | "Do not change files, git state, or external systems." |
| `comment-sicko` | any | `reviewer` | "Read `skill://pstack-comment-sicko` and follow it as your persona. Report only." |

Model families:

- `task` runs on the `task` role, and `scout` on the `smol` role. `reviewer` runs on GPT through `task.agentModelOverrides`. The main session runs on Claude Opus.
- A panel or a "same prompt on a different model" second opinion that is read-only uses `reviewer` for GPT and `task` with the read-only line for the other family.
- A panel that writes code on two families (for example `arena` runners) needs the user's model tags. When the user tags models with `^`, omp registers them as agents `m1`, `m2`, and so on, each a writable `task` pinned to its model. Use one tagged agent per family. Without tags, run the writable spawns on `task` and say in the reply that they ran on one family.
- `grok-` slugs map to GPT. omp does not use Grok.

Reasoning level: the spawned agents use `auto` thinking. When a spawn omits `effort`, omp classifies the child's first prompt and picks its level. The classifier reads only `solutionSpace`, so write it to show how open the problem is, not how large it is. Set `effort` only when the skill tells you to change the level:

| pstack instruction | `effort` |
|---|---|
| Role default (`xhigh` in a skill default or in a model slug) | Omit. `auto` decides. |
| Raise the level for the hardest or subtlest work, or `max` | `hi` |
| Lower one step, for judgment | `med` |
| Lower two or more steps, for routine work | `lo` |

`effort` maps to the lowest, middle, or highest level that the resolved model supports. Fast mode (`-fast` slugs) has no per-spawn control in omp. Ignore it.

`~/.cursor/rules/pstack-models.mdc` does not exist in omp. Each skill then uses its own default model per the rules above. `/setup-pstack` is not available in omp: tell the user to edit `modelRoles` or `task.agentModelOverrides` in `~/.omp/agent/config.yml` instead. Do not change them from a skill.

Other `Task` parameters:

| Cursor | omp |
|---|---|
| `run_in_background: true` | Default behavior. Results arrive as messages. Use `wait` only when you have no other work. |
| `environment: "cloud"` | Not available. Run the spawn locally. |
| Resume a subagent | `write agent://<id>` with the follow-up message. |
| Readonly mode strips MCP access | omp keeps MCP tools in every agent. Ignore this limit. |
| `generalPurpose` substituted for `poteto-agent` | Do not do this. Use `task` with the `poteto-agent` first line from the table above. |

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
