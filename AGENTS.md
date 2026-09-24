# Codex Agent Guidance

This is a Lazarus / Free Pascal project for DcsUtils. Prefer small, focused changes that match the existing Pascal style, form layout conventions, and test structure.

## Project Subagents

Codex can delegate independent work to subagents when the user explicitly asks for delegation, subagents, or multi-agent work. Use these local role prompts when spawning subagents:

- Planner: `.agents/skills/planner/SKILL.md`
- Developer: `.agents/skills/developer/SKILL.md`
- UI Developer: `.agents/skills/ui-developer/SKILL.md`
- Code Reviewer: `.agents/skills/code-reviewer/SKILL.md`

Subagents should inherit the current model and reasoning settings unless the user explicitly requests a different model.

## Orchestration Rules

- Clarify the user's goal as a concrete objective before splitting work.
- Skip Planner for single-error fixes, one-file or one-method edits, config/build tweaks, and tasks that can be stated unambiguously in a few sentences.
- Use Planner for multi-file features, UI plus logic changes, or requests with real ambiguity.
- Send form, `.lfm`, control layout, and event-wiring work to UI Developer.
- Send core Pascal logic, units, and tests to Developer.
- For non-trivial changes, ask Code Reviewer to review the relevant diff before finalizing.
- Batch all review fixes into one follow-up instead of one fix per issue.
- Track todos only when there are three or more real steps.
- Keep reports concise: files touched, verification performed, review outcome, and remaining follow-ups.

## Local Development Notes

- Search with `rg` first.
- Do not revert user changes or unrelated work.
- Update or add tests under `test/` when behavior changes.
- Verify `.lfm` files and paired `.pas` declarations stay in sync.
- Build or run focused tests when practical, and report if verification could not be run.
