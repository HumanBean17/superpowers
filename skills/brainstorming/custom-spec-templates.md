# Custom Spec Templates

Specs are freeform by default. This guide explains how to opt into a custom spec
template so the brainstorming skill writes specs to a structure you define — and
how the skill stays loose when a task doesn't fit that structure.

## Opt-in

Place a file named `spec-template.md` beside this skill's `SKILL.md`:

    skills/brainstorming/spec-template.md

- **Present** → the agent structures the written spec around it.
- **Absent** → specs are freeform. Nothing else changes.

The agent reads the template at spec-writing time; it never writes to it. No
template ships with the skill — this is pure opt-in.

The template affects **only the written spec document**. It never changes the
brainstorming conversation: the clarifying questions, approach options, and
design presentation proceed exactly as usual.

## Template format

A markdown outline. Each section is a heading plus short guidance.

- By default, every section is a **suggestion** — include it when it applies,
  omit it silently when it doesn't.
- Mark a section **required** by suffixing its heading with `[required]`. A
  required section triggers the deviation ask (below) if the task can't
  meaningfully fill it.

The template inherits the brainstorming skill's core rule: a spec carries
**design and contracts** (references to classes, methods, fields, DTOs, JSON
Schema, configs) — **not implementation code** (no method bodies, no
algorithms). Writing code is the implementer's job, not the spec's.

`[required]` is template metadata only. Strip it from the written spec.

### Example `spec-template.md`

    # Spec

    ## Overview
    What this is and why.

    ## Goals / Non-Goals [required]
    Explicit in-scope and out-of-scope.

    ## Design
    Architecture, components, data flow. Reference classes/methods/DTOs — no
    implementation code.

    ## API Contract [required]
    JSON Schema or signature for any external surface. Omit if the change has none.

## The fit check

After the user approves the design and before writing the spec, map the approved
design onto the template's sections and sort every mismatch into one of three
buckets:

1. **Required-doesn't-apply** — a `[required]` section the task cannot
   meaningfully fill.
2. **Needed-missing** — the task needs a section the template doesn't have.
3. **Conflict** — template guidance clashes with the task.

- No mismatches → write the spec following the template structure.
- Any mismatches → present **all** of them in a single message (the deviation
  ask) and wait. Do not silently drop a required section or silently invent a
  new one.
- Dropping a non-required (suggestion) section never triggers an ask.

## The deviation ask

One batched message, each item with a concrete question. For example:

> Before writing the spec I checked it against your `spec-template.md`. It
> doesn't fit in these ways:
>
> - **[required] 'API Contract'** — this is a UI-only change with no external
>   surface. OK to omit?
> - **Missing section 'Migration Plan'** — the task needs a data migration your
>   template has no section for. OK to add it?
>
> Proceed with these deviations, or should I adjust the design to fit the
> template?

- **Approve** → write the spec to the agreed (deviated) structure.
- **Adjust** → revise the design to fit the template, then re-run the fit check.
