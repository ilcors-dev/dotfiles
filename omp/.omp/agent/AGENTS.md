# User instructions

Apply the writing guidance below to every response and to every document that people read, in every session and in every subagent.

@writer.md

## Missing skill references

A skill can reference another skill or a file, for example `skill://<name>`, `skill://<name>/<path>`, `$<name>`, or a relative path such as `../<name>/SKILL.md`. When a referenced skill or file is not found, tell the user. Do not guess its content, and do not silently skip it.

- Name the skill that contains the reference, the missing reference, and the error.
- Continue with the parts of the task that do not depend on the missing reference, and say which steps you skipped.
- In a subagent, put the same report in your result so that the parent can relay it to the user.
