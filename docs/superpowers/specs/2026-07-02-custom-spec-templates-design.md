# Custom Spec Templates for the Brainstorming Skill

**Date:** 2026-07-02
**Status:** Design — pending user review
**Scope:** `skills/brainstorming/`

## Overview

Add optional, opt-in support for custom spec templates to the `brainstorming` skill. A user places a `spec-template.md` file beside `SKILL.md`; when present, the agent structures the written spec around it. When absent, behavior is unchanged (freeform specs). The feature is deliberately loose: when a task does not fit the template, the agent detects the mismatch and asks the user before deviating, rather than silently forcing or ignoring the template.

## Goals

- Let users enforce a consistent spec structure without changing default behavior for anyone who doesn't opt in.
- Keep templates non-rigid: optional sections drop silently; only `[required]` sections and structural mismatches prompt an ask.
- Fit the existing sibling-file convention already used by this skill (`visual-companion.md`, `spec-document-reviewer-prompt.md`) and the project's lean-`SKILL.md` direction.

## Non-Goals

- Plan templates for the `writing-plans` skill (separate future work; the parallel `plan-document-reviewer-prompt.md` already exists).
- Modifying `spec-document-reviewer-prompt.md` to validate template adherence (possible follow-up, out of scope here).
- Shipping any default or example template (pure opt-in — no `spec-template.md` ships).
- Constraining the brainstorming conversation itself. The template affects **only the written spec document**, never the clarifying questions, approach exploration, or design presentation.

## Discovery & Lifecycle

- At spec-writing time — after the design is approved and before the spec is written — the agent checks for `spec-template.md` in the brainstorming skill directory (beside `SKILL.md`).
- **Present** → use it to structure the written spec.
- **Absent** → freeform, exactly as today. Zero behavior change.

Lifecycle is read-only: the agent reads the template each session; it never writes to it.

## Template File Format

A markdown outline. Each section is a heading plus short guidance.

- **Default:** a section is a *suggestion* — the agent includes it when it applies and omits it silently when it doesn't.
- **Required:** mark a section by suffixing its heading with `[required]`. A required section triggers the deviation ask if the task can't meaningfully fill it.
- The template inherits the skill's existing rule: specs carry **design and contracts** (class / method / field / DTO / JSON-Schema references), **not implementation code** (no method bodies, no algorithms).
- `[required]` is template metadata only — it is stripped from the written spec output.

Example `spec-template.md`:

```markdown
# Spec

## Overview
What this is and why.

## Goals / Non-Goals [required]
Explicit in-scope and out-of-scope.

## Design
Architecture, components, data flow. Reference classes/methods/DTOs — no implementation code.

## API Contract [required]
JSON Schema or signature for any external surface. Omit if the change has none.
```

## Fit-Check Procedure

A new procedural step in the brainstorming checklist, placed **after design approval and before writing the spec** (between the current "Present design" / approval step and "Write design doc").

1. Look for `spec-template.md` beside `SKILL.md`. If absent, skip to writing the spec freeform.
2. Map the just-approved design onto the template's sections.
3. Categorize any mismatch into three buckets:
   - **Required-doesn't-apply** — a `[required]` section the task cannot meaningfully fill.
   - **Needed-missing** — the task needs a section the template lacks.
   - **Conflict** — template guidance clashes with the task.
4. If there are **no mismatches**, write the spec following the template structure.
5. If there **are mismatches**, present all of them in a single message (the deviation ask) and wait.

## Deviation-Ask Behavior

The mismatch list is presented as one batched message, each item with a concrete question. Example:

> Before writing the spec I checked it against your `spec-template.md`. It doesn't fit in these ways:
>
> - **[required] 'API Contract'** — this is a UI-only change with no external surface. OK to omit?
> - **Missing section 'Migration Plan'** — the task needs a data migration your template has no section for. OK to add it?
>
> Proceed with these deviations, or should I adjust the design to fit the template?

Outcomes:

- **Approve** → write the spec to the agreed (deviated) structure.
- **Adjust** → revise the design to fit the template, then re-run the fit check.
- Dropping a non-required (suggestion) section **never** triggers an ask — that is the "not so tight" property.

## Wiring (design-level)

Two artifacts change; no default template ships.

1. **`skills/brainstorming/SKILL.md`** — add:
   - One new checklist item: the fit check, placed between "Present design" / approval and "Write design doc".
   - A short "Custom Spec Template" subsection that states the opt-in rule (template present → use it; absent → freeform) and points to the sibling guide for format and procedure. Keeps `SKILL.md` lean.
2. **`skills/brainstorming/custom-spec-templates.md`** (new sibling) — holds: the template file format (headings, `[required]` tag, no-code rule), the fit-check procedure, the deviation-ask script, and a worked example. Mirrors how `SKILL.md` defers to `visual-companion.md` for detail.

The existing `spec-document-reviewer-prompt.md` is untouched in this change.

## Risks & Verification

- This is behavior-shaping skill content. The repo's `CLAUDE.md` requires eval evidence for skill changes and a high bar for touching tuned content. Before relying on this, run adversarial pressure-testing across sessions (per "Skill Changes Require Evaluation").
- Lightweight verification to include in the plan:
  1. A session with a `spec-template.md` containing a `[required]` section that doesn't apply to the task → the agent performs the fit check and asks before deviating.
  2. A session with no `spec-template.md` → behavior is identical to today (freeform, no fit-check step visible).
  3. A session where the task needs a section the template lacks → the "Needed-missing" ask fires.
- The working tree currently has uncommitted modifications to `skills/brainstorming/SKILL.md`. The implementation plan must account for this — changes are applied onto the current working-tree state, not clobbering the existing WIP.
