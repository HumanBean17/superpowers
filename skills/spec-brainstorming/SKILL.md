---
name: spec-brainstorming
description: "Two-round spec lifecycle for teams with a system analyst and a developer. Round 1 — analyst (build): produce a draft spec (Status: draft) for developer review, not a plan. Round 2 — developer (review): review the draft top-down and either leave it as draft or approve it as plan-ready (Status: in_progress → writing-plans). Carries a shared Open Questions section. Invoke explicitly for a spec build/review round; for general creative work use the brainstorming skill."
---

# Spec Brainstorming (Analyst build round + Developer review round)

Turn ideas into plan-ready specs through a two-round lifecycle tailored for a team with a **system analyst** and a **developer**. The same design thinking drives both rounds — they differ only in entry state, terminal action, and the status they write.

<OPT-IN>
This skill is **opt-in**. Invoke it only when the user explicitly requests a spec build or spec review round — e.g., they name this skill, ask to "build a spec", "review the draft spec", or reference the analyst/developer rounds. Do NOT self-invoke for general "let's build X" requests, new features, or open-ended creative work. Route those to the regular `brainstorming` skill instead. If you were loaded on a marginal match and the request is general creative work, say so and use `brainstorming`.
</OPT-IN>

<HARD-GATE>
Do NOT write any code, scaffold any project, or invoke any implementation skill until a design has been presented and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
In **build mode**: additionally do NOT invoke `writing-plans` — the round ends at a draft spec, full stop.
In **review mode**: do NOT invoke `writing-plans` unless the spec is being approved and its `Status` is being set to `in_progress`.
</HARD-GATE>

## Core Principles

These principles override the rest of this skill when in conflict.

1. **Context before code.** Before exploring the codebase, carefully read the context the user provided — the task description, linked tickets, attached files, references, and any constraints stated in the message. Only then explore the code. The design must reflect what the user actually asked for, not what you assume.
2. **Specs carry design, not code.** The spec describes WHAT to build and WHY, with references to classes, methods, fields, configurations, tables, DTOs, and contracts (JSON Schema, schemas, config). It MUST NOT contain implementation logic — method bodies, algorithms, or actual code. Writing code is the job of the agent that implements the plan. Your job here is to design.
3. **Same depth for both roles — never role-gate detailization.** The line between a gap an analyst would catch and one a developer would catch is thin, so both rounds see the same data and may go as deep as the conversation needs. Never mute detail based on who is driving: "I'm an analyst, skip the Java class names" and "I'm a developer, skip the JSON schema" are both wrong. When something genuinely can't be answered in the current round, defer it to **Open Questions** rather than skipping or guessing.
4. **Calibrate to a human-reviewable altitude.** The spec is the reviewer's surface; the plan is the agent-facing artifact that carries per-task detail (what one task needs to be written, not the design itself). The spec template sets the spec's sections; this governs only their altitude. Keep each section at design altitude — if it sprawls into per-task detail a human would skim rather than review, push it down into the plan, not into the spec — and never into code (Principle #2). This sets the *written spec's* altitude; Principle #3 still governs how deep the *conversation* goes — explore fully, then capture at review altitude, deferring per-task detail to the plan. But keep it concrete enough that a plan agent could expand the spec into tasks.
5. **The spec describes one change to the system, not a log of its own revisions.** The body states the target design of the change in the present tense and is **rewritten in place** as the design evolves — never as a changelog of the document (no "Deleted:", "Removed:", "Changed:", "Previously:", before/after, edit-dates). The document's revision history is git commits + the archived ADR. *Open Questions is the exception: it records decisions by design.* This governs build-mode iteration on an existing draft too — rewrite the body, don't annotate it.

## The Spec Lifecycle

A spec moves through two rounds and carries a status:

- **Round 1 — Build (analyst):** turn an idea into a spec (unless the user declines the spec for a trivial change — then no spec is written and there is no review round). When a spec is written its status is **always `draft`** — it must be reviewed before it can be implemented. This round never writes a plan.
- **Round 2 — Review (developer):** take an existing `draft` spec, review it top-down (common → details), refine it, and resolve or accept its Open Questions. Terminal state is either:
  - **`draft`** — still has open questions, or the reviewer is not ready to approve. Stop here. Or
  - **approved → `in_progress`** — every Open Question is resolved or explicitly accepted; invoke `writing-plans`.

The `Status` field has four values — **`draft`**, **`in_progress`**, **`implemented`**, **`released`** — but this skill only writes the first two. `draft → in_progress` is the approval event in review mode (not a separate stored state). Once a spec is `in_progress` the rest of the lifecycle is owned elsewhere: `superpowers:finishing-a-development-branch` sets `implemented` (tests green) and `released` (merge → archive), and `superpowers:spec-update` reconciles or evolves an `in_progress`/`implemented` spec. See `superpowers:spec-update` for the full state machine.

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval. What's optional is the written spec (see Build mode) — the design conversation itself never is.

## Step 0 — Determine Mode

This is Checklist item 1 — resolve it before anything else. Pick the mode from the entry signal:

- **Review mode** — the user pointed at an existing draft spec (a path, "review the spec", "developer round"), or there is exactly one draft spec under `docs/superpowers/specs/active/` matching the topic (matched by filename slug or the path given). If two or more drafts could match, list them and ask the user which to review before proceeding.
- **Build mode** — the entry is an idea/context with no existing draft spec ("build a spec", "analyst round", a new feature to design). If a draft for this topic already exists and the user wants to iterate (analyst re-running build), that's allowed: keep `Status: draft` and carry forward the existing Open Questions (append-only — never delete). Rewrite the body in place under the snapshot gate (Core Principle #5) — don't annotate the prior draft with what changed.
- **No draft found in review mode** — tell the user, then offer to start in build mode. Don't fail silently.
- **Override** — the user can always force a mode ("I'm the analyst, building" / "I'm reviewing draft X"). Honor it.

If you can't tell, ask one question: *"Are we building a new spec from an idea (analyst round), or reviewing an existing draft spec (developer round)?"*

## Checklist

Create a task for each item and complete them in order. Items 3, 6, 7, 9, and 12 branch by mode.

1. **Determine mode** — build vs review (Step 0 above).
2. **Read the provided context** — the task description, linked tickets, attachments, and any stated constraints. Parse intent and boundaries before touching the codebase.
3. **Load the existing spec (review mode only)** — read the draft spec end to end; note its `Status` and its Open Questions. If the draft lacks a `Status` line or an `## Open Questions` section (e.g., it was produced by the regular `brainstorming` skill), treat it as `Status: draft` with an empty Open Questions section and add both before proceeding.
4. **Explore project context** — check files, docs, recent commits.
5. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria. In review mode, frame these as gaps you found while reading the draft.
6. **Propose 2–3 approaches** — with trade-offs and your recommendation; YAGNI ruthlessly — drop unnecessary features from every approach. In review mode, skip if the draft's approach is sound; otherwise propose alternatives to what the draft assumes.
7. **Present/refine design** — in build mode present the design in sections scaled to complexity, getting approval after each. In review mode walk the draft top-down section by section (see Review mode). Get approval on changes.
8. **Template fit check** — if a project-level `docs/superpowers/spec-template.md` exists, map the design onto it; surface every mismatch in one message and ask before deviating. Skip if absent. In review mode, re-check the draft against the template and surface any deviations the analyst introduced.
9. **Write/update the spec** — in build mode, first ask the user whether to write a spec. If they decline (trivial change), go to the decline terminal (see Build mode). Otherwise: build creates a new file at `docs/superpowers/specs/active/YYYY-MM-DD-<topic>-design.md` (today's date, topic derived from the feature slug); review updates the loaded draft **in place at its existing path** (do not rename or re-date it). If the spec is modular (the template's modular flag, or the user asked to convert — see [Modular Specs](#modular-specs)), write/update it as the modular layout (`00-index.md` + one file per section) following the spec-access protocol — edit the relevant section file in place, not the whole spec; Status and Open Questions live in `00-index.md`. Set `Status: draft` in both modes — promotion to `in_progress` happens later, after user approval. Maintain the Open Questions section. Commit.
10. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope, code leakage, status correctness, and Open Questions integrity (see below).
11. **User reviews the written spec** — ask the user to review the spec file.
12. **Transition** — branches by mode (see Build mode / Review mode terminals below).

## Build Mode (Analyst Round)

Posture: **build the design up from intent.** You are designing from scratch (or from a prior idea).

**Flow:** read context → explore → clarifying questions one at a time → propose 2–3 approaches → present the design in sections, approving each → template fit check → write the spec.

**Open Questions handling (active throughout):**
- If the user deflects one of your questions — *"I don't know yet", "let's leave that", "that's for the developer"* — record it as an Open Question and continue. Do not block the design on it.
- If the user says *"add this to open questions"* (or similar) at any point, record it immediately.
- You may also propose Open Questions yourself when you hit something genuinely undecided.

**Spec status:** when a spec is written, its `Status` line is **`draft`**.

**Terminals (item 12 in build mode):**
- **Spec written** — after the user reviews the spec, **stop**. Do NOT invoke `writing-plans`. Do NOT write code. The deliverable is a draft spec handed off to the developer review round. Tell the user: *"Draft spec ready at `<path>` (Status: draft). Hand it to a developer to run the review round."*
- **Spec declined** (user said no at item 9) — **stop**. Do NOT write code or invoke `writing-plans`; this skill's lifecycle doesn't apply without a spec. If the user wants to implement directly, route them to the regular `brainstorming` skill.

## Review Mode (Developer Round)

Posture: **review and refine an existing draft**, top-down (common → details).

**Load the draft** (item 3): read it end to end; note its current `Status` and every Open Question.

**Walk the draft section by section** (item 7), from the highest-level section (architecture, goals) down to the most detailed (contracts, data shapes, error handling). If the draft is modular, read `00-index.md` first (Status and Open Questions live there), then walk each section file in TOC order — one section file per step, not the whole spec at once. For each section:
- Summarize what's there in a sentence or two, so the user knows what you read.
- Flag gaps, ambiguity, internal contradictions, missing error/edge cases, and any implementation logic that leaked in (spec must carry design, not code).
- Ask **one** clarifying question at a time about what you flagged. Prefer multiple choice.
- Propose concrete fixes and apply them once the user agrees. Multiple unrelated fixes in one section can be batched, but each unresolved point is its own question.
- If a point can't be settled in this round, defer it to Open Questions.

**Walk the Open Questions** (after the section pass): for each item, try to **resolve** it — decide, record the decision inline, and reflect it in the spec body. If it can't be resolved now, **accept/defer** it: record owner + rationale + when to revisit, and leave a clear note. Both the analyst (in a later build re-run) and the developer can create and resolve items.

**Spec status (item 9):** the spec is written/updated as `Status: draft`. Promotion to `in_progress` is a separate step, done only at the terminal after the user approves.

**Terminal (item 12 in review mode):**
- **Not approving** (Open Questions remain unresolved/unaccepted, or the reviewer isn't ready) — after the user reviews the spec, **stop**. The spec stays `Status: draft`. No `writing-plans`, no code.
- **Approving** — only when **every Open Question is resolved or explicitly accepted** (every item `- [x]` with a recorded resolution). Edit the `Status` line to `in_progress`, commit, then invoke the `writing-plans` skill. Do NOT invoke any other skill. If the user declines promotion at the gate, leave the spec at `Status: draft` and stop.

## Open Questions

A shared section in the spec, used as the escape hatch for anything a round can't settle. **Both rounds create and resolve items.** Format:

```markdown
## Open Questions

- [ ] **Q:** <the question, stated plainly>
      Why it matters / what it blocks: <context — the decision this gates, or the risk of leaving it open>
      Raised by: analyst | developer
      Owner: <name or role, optional>

- [x] **Q:** <resolved question>
      Resolution: <the decision> — folded into <section> on <date>
      Raised by: analyst | developer  Resolved by: <name or role>

- [x] **Q:** <accepted/deferred question>
      Resolution: Accepted/deferred — <rationale>. Owner: <name>. Revisit: <trigger or "never">.
      Raised by: analyst | developer  Resolved by: <name or role>
```

Rules:
- **Never delete** a checked (`- [x]`) item — resolved, accepted, or deferred. Mark it `- [x]` and record the resolution so the decision history survives; resolved decisions must also be reflected in the spec body. To retire an unresolved item that has become moot, check it and record why rather than deleting it.
- An **accepted/deferred** item is still checked (`- [x]`) — its resolution is "we knowingly accept this risk / defer it" with owner + rationale.
- To promote a spec to `in_progress`, the Open Questions section must exist **and** every item must be `- [x]`. Unchecked items block promotion; the spec stays `draft`.

## Status Field

A single visible line, placed immediately under the spec's `#` title (for a modular spec, that title is in `00-index.md`):

```markdown
**Status:** draft
```

or

```markdown
**Status:** in_progress
```

This skill writes only `draft` and `in_progress`:

- Build mode always writes/leaves `draft`.
- Review mode leaves `draft`, or flips to `in_progress` at the terminal on approval (gated on Open Questions).

The later statuses are written by other skills — `implemented` (plan executed, tests green) and `released` (merged → archived as ADR) by `superpowers:finishing-a-development-branch`; updates to an `in_progress`/`implemented` spec by `superpowers:spec-update`. This skill never sets them.

## Spec Self-Review

After writing/updating the spec, look at it with fresh eyes:

1. **Status correctness:** is the `Status` line present? At this stage it must read `draft` in both modes — promotion to `in_progress` happens later, after user approval (so don't pre-set it here).
2. **Open Questions integrity:** does the section exist? Is every item well-formed? Are resolutions recorded and reflected in the body? No item deleted.
3. **Template conformance** (if `docs/superpowers/spec-template.md` is present): required sections present, optional ones filled or dropped.
4. **Code leakage:** did implementation logic (method bodies, algorithms) sneak in? Remove it — keep only design, contracts, and references.
5. **Altitude check:** per-task detail a human would skim rather than review (what one task needs, not the design itself) belongs in the plan — but anything the spec template reserves a section for stays, at design altitude. Then confirm the spec still names the components, contracts, and key decisions a plan agent needs to expand it into tasks — abstract, not vague.
6. **Placeholder scan:** any "TBD", "TODO", incomplete sections, or vague requirements? Either fix them inline or move them into Open Questions with context — don't leave bare placeholders.
7. **Internal consistency:** do sections contradict each other? Does the architecture match the feature descriptions?
8. **Scope check:** focused enough for a single implementation plan, or does it need decomposition?
9. **Ambiguity check:** could any requirement be read two ways? Pick one and make it explicit, or defer to Open Questions.
10. **Snapshot/log check:** any revision-log text in the body — e.g. `Deleted:`, `Removed:`, `Changed:`, `Updated:`, `Previously:`, `Old:`, `New:`, `was →`, `~~strikethrough~~`, before/after framing, edit-dates? (List is exemplary.) Rewrite each span as flat present-tense target design of the change. The body describes the change; it is not a changelog of itself. *(Open Questions' checked items are decision records, not log entries — leave them; no other section is exempt.)*
11. **Modular integrity (if the spec is modular):** `00-index.md` is the only file carrying a `Status:` line or an `## Open Questions` heading; every section file appears in the TOC and every TOC entry has a file; Status and Open Questions are not duplicated in any section file.

Fix issues inline. No need to re-review — just fix and move on. Note: a legitimate Open Question is **not** a placeholder — don't "fix" it by inventing an answer.

## User Review Gate

After the self-review passes, ask the user to review the spec before transitioning:

> "Spec written/updated and committed to `<path>` (Status: <status>). Please review it and let me know if you want changes before we move on."

Wait for the response. If they request changes, make them and re-run the self-review. Only proceed to the terminal once they approve.

## Process Flow

```dot
digraph spec_brainstorming {
    rankdir=TB;
    "Determine mode" [shape=diamond];
    "BUILD: read context\n→ explore → questions\n→ approaches → design" [shape=box];
    "REVIEW: load draft\n→ walk top-down\n→ flag + fix → open Qs" [shape=box];
    "Write spec\n(Status: draft)" [shape=box];
    "Self-review + user review" [shape=box];
    "All open Qs resolved\nor accepted?" [shape=diamond];
    "User approves\npromotion?" [shape=diamond];
    "Status: in_progress" [shape=box];
    "Status: draft (stop)" [shape=doublecircle];
    "writing-plans" [shape=doublecircle];

    "Determine mode" -> "BUILD: read context\n→ explore → questions\n→ approaches → design" [label="build"];
    "Determine mode" -> "REVIEW: load draft\n→ walk top-down\n→ flag + fix → open Qs" [label="review"];
    "BUILD: read context\n→ explore → questions\n→ approaches → design" -> "Write spec\n(Status: draft)";
    "REVIEW: load draft\n→ walk top-down\n→ flag + fix → open Qs" -> "Write spec\n(Status: draft)";
    "Write spec\n(Status: draft)" -> "Self-review + user review";
    "Self-review + user review" -> "Status: draft (stop)" [label="build mode;\n or review, not promoting"];
    "Self-review + user review" -> "All open Qs resolved\nor accepted?" [label="review mode,\n considering promotion"];
    "All open Qs resolved\nor accepted?" -> "Status: draft (stop)" [label="no"];
    "All open Qs resolved\nor accepted?" -> "User approves\npromotion?" [label="yes"];
    "User approves\npromotion?" -> "Status: draft (stop)" [label="no"];
    "User approves\npromotion?" -> "Status: in_progress" [label="yes"];
    "Status: in_progress" -> "writing-plans";
}
```

**Terminal state.** Build mode ends at a `draft` spec — handoff, no plan. Review mode ends at either a `draft` spec (stop) or, on approval, `in_progress` → `writing-plans`. In every case code is written only later, by the plan's implementer.

## Custom Spec Template

Specs are freeform unless the project provides `docs/superpowers/spec-template.md` — a project-level file read at spec-writing time and never written to. It shapes only the written spec, never the conversation.

**Format.** A markdown outline of sections, each a suggestion unless its heading is suffixed `[required]` (strip that tag from the output).

**Modular.** If the template's first line is `<!-- superpowers: modular -->`, the spec is written as the modular layout (see [Modular Specs](#modular-specs) below) — `00-index.md` plus one file per `##` section — instead of a single file. `[required]` tags still apply, enforced across the section files. In review mode, re-check that the analyst wrote each `[required]` section as its file. The fit check is unchanged: map the design onto the template's sections.

**Fit check.** Map the design onto the template. Drop non-required sections silently. For any `[required]` section that doesn't fit, any section the task needs but the template lacks, or any conflict — present all mismatches in one batched message and ask before deviating.

> If your project's spec template should reserve a place for **Open Questions** and **Status**, make those sections `[required]` in the template so the fit check enforces them.

## Modular Specs

A spec is normally a single file. A **large** spec — one that bloats any agent's context when fetched or edited — may instead be **modular**: a directory of small files an agent navigates by need instead of loading whole. Both rounds of this skill read and rewrite the spec, so modular specs keep a large spec from swallowing the round's context.

### When a spec is modular

A spec becomes modular in one of two ways — never auto-converted mid-edit:

- **From creation** — the project's spec template carries the marker `<!-- superpowers: modular -->` (see Custom Spec Template above). Build mode creates the modular layout.
- **On request** — the user asks this skill to "make this spec modular," and it converts an existing single-file spec into the modular layout. See Convert, below.

### The modular layout

A modular spec is a directory named by the same date+topic slug a single-file spec would carry, containing:

```
docs/superpowers/specs/active/YYYY-MM-DD-<topic>/
  00-index.md          # control surface — always loaded first
  01-<slug>.md
  02-<slug>.md
  ...
```

- Each top-level `##` section of the design is its own file, numbered `NN-<slug>.md` for stable order (insert a section by renumbering so the order stays stable).
- `00-index.md` is the entry point. It carries — and only carries — the title; the **`Status:`** line; the **`## Open Questions`** section; a **Table of Contents** (one row per section file: `filename → one-line summary`); and a short **elevator** (goal + 2–3 sentence architecture). No design detail lives in the index.
- Section files carry the design content for their topic, at design altitude (no code), under the same rules as a single-file spec.

**Status and Open Questions live only in `00-index.md`.** They are the lifecycle control surface, and the index is the one file every operation reads first — so no round ever hunts across files for status or an unresolved question.

### The spec-access protocol

Every spec-touching skill branches once on whether the path is a directory containing `00-index.md` (modular) or a `.md` file (single), then:

1. **Read the entry point first.** Single-file → read the whole file. Modular → read `00-index.md` only.
2. **Load sections on demand.** From the index's TOC, read only the section file(s) the operation needs. Never read all sections unless the operation needs the whole design (planning does, and so does reconcile in `spec-update`).
3. **Edit in place.** Single-file → edit the file. Modular → edit the specific section file, or the index for Status / Open Questions / TOC / elevator. Never rewrite the whole spec to change one section.
4. **Keep the TOC honest.** Adding, removing, or renaming a section file updates the index's TOC in the same change.

### In this skill (build vs review)

- **Build mode:** if the template is modular, create `00-index.md` + one file per `##` section. Iterate on a section by editing its file, not the whole spec.
- **Review mode:** read `00-index.md` first, then walk each section file top-down (one file per step). Resolve Open Questions and set Status in the index. Approval flips `00-index.md`'s `Status:` line to `in_progress`, which `writing-plans` then reads.

### Convert (single-file → modular, on request)

When the user asks to modularize a single-file spec, this skill:

1. Checks the target is a single-file spec, not already modular, not `released`/archived.
2. Creates `docs/superpowers/specs/active/<topic>/` — `<topic>` is the existing filename with `-design.md` stripped (e.g. `2026-08-07-orders-redesign`), matching the modular layout's directory name.
3. Builds `00-index.md` from the title, the `Status:` line, the `## Open Questions` section, a generated TOC, and an elevator (goal + opening lines).
4. Splits each top-level `##` section (except Open Questions) into `NN-<slug>.md`, numbered in source order.
5. Deletes the old single file and commits. Status is unchanged.

A spec with no `##` structure (freeform) can't split cleanly — say so, and ask the user to restructure or stay single-file.

