---
name: spec-update
description: "Update an existing spec at Status: in_progress or implemented. Two intents — reconcile: rewrite the body so it describes the change accurately as built or refined, scope unchanged, no plan; evolve: accept new scope and hand the DELTA to writing-plans (implemented → in_progress), then execute just the delta. The body is rewritten in place under a snapshot gate (no inline history). Invoke explicitly to update an implemented or in-progress spec; drafts belong to spec-brainstorming; released specs are terminal."
---

# Spec Update (Reconcile / Evolve an existing spec)

Keep an existing spec honest as reality drifts or scope grows — **without turning it into a changelog.** The spec describes one change to the system; this skill keeps that one description current.

<OPT-IN>
This skill is **opt-in**. Invoke it only when the user explicitly asks to update an existing `in_progress` or `implemented` spec — e.g., they name this skill, say "the spec drifted", "reconcile the spec to what we built", or "add X to the implemented spec". Do NOT self-invoke for new features or open-ended creative work (route to `brainstorming`), for building/reviewing a **draft** (route to `spec-brainstorming`), or for a **released/archived** spec (route to a new spec citing the archived ADR).
</OPT-IN>

<HARD-GATE>
Do NOT write code — the body is rewritten in place, at design altitude, never as a log of its own revisions. **Status:** reconcile leaves it unchanged; evolve flips `implemented → in_progress` (or leaves `in_progress`); this skill never sets `implemented` or `released`. In **reconcile** mode: do NOT invoke `writing-plans` (scope is unchanged). In **evolve** mode: `writing-plans` is the only terminal, for the new/changed scope only — never regenerate the whole plan. Do NOT edit a `draft` (route to `spec-brainstorming`) or a `released` spec (route to a new spec via `brainstorming`/`spec-brainstorming`).
</HARD-GATE>

## Core Principles

These principles override the rest of this skill when in conflict.

1. **Context before code.** Read the spec, its plan, and **what was actually built** (the diff, the code, recent commits) before touching the body. An update that ignores built reality invents drift.
2. **Specs carry design, not code.** Reference classes, methods, fields, configs, DTOs, contracts; no method bodies, algorithms, or actual code.
3. **The spec describes one change to the system, not a log of its own revisions.** The body states the target design of the change (what gets added, changed, or removed, and why) in the present tense. As the design evolves it is **rewritten in place** to keep that single description current and complete. The body must NOT become a changelog of the document — no "Deleted:", "Removed:", "Changed:", "Previously:", no before/after, no edit-dates. The spec describes that one change; the document's revision history lives in git commits and the archived ADR. *Open Questions is the only exception: it records decisions by design, not document revisions.*
4. **Calibrate to a human-reviewable altitude.** Per-task detail (what one task needs written, not the design itself) belongs in the plan, not the spec — and never in code. Keep the spec concrete enough that a plan agent can expand it into tasks.

## The Spec Lifecycle

A spec carries one of four statuses. This skill owns the post-`draft` re-entry; create/approve happen in `spec-brainstorming`, completion/release in `finishing-a-development-branch`.

```
draft ──(spec-brainstorming / brainstorming approves)──▶ in_progress
in_progress ──(finishing: tests green)──▶ implemented
implemented ──(finishing: merge)──▶ released   [terminal → archive/]
implemented ──(spec-update: evolve)──▶ in_progress   [non-waterfall re-entry]
released ──▶ none (write a NEW spec citing the archived ADR)
```

| Status | Means | Written by |
|--------|-------|------------|
| `draft` | written, awaiting approval | `spec-brainstorming` |
| `in_progress` | approved; plan being written or executed | `spec-brainstorming` / `brainstorming` (approval); `spec-update` (evolve re-entry) |
| `implemented` | plan executed, tests green, not yet merged | `finishing-a-development-branch` |
| `released` | merged into base branch; archived as ADR | `finishing-a-development-branch` |

## Step 0 — Determine Intent

Resolve before anything else. The entry signal decides:

- **Reconcile** — scope is unchanged; the body just no longer matches what was built, or needs altitude/consistency fixes. ("the spec drifted", "make the spec match reality".)
- **Evolve** — new or changed scope is being added to the same change. ("add X to the spec", "we also need Y".)
- **Wrong status** — if the target is a `draft`, route to `spec-brainstorming`; if `released`/archived, route to a new spec citing the ADR. Say so and stop.
- **Override** — the user can force an intent ("just reconcile, don't add scope"). Honor it.

If you can't tell, ask one question: *"Is the scope of this change staying the same (reconcile the description to reality), or are we adding/changing scope (evolve)?"*

## Checklist

Create a task for each and complete in order. Items 1, 5, 6, and 9 branch by intent.

1. **Determine intent** — reconcile vs evolve (Step 0). Refuse `draft`/`released` targets.
2. **Read the provided context** — what the user says drifted, or what scope is being added.
3. **Load the spec, its plan, and built reality** — read the spec end to end; read its plan under `docs/superpowers/plans/active/`; inspect the diff/code/commits for what was actually built. Note the `Status`.
4. **Explore project context** — files, docs, recent commits.
5. **Ask clarifying questions** — one at a time. In reconcile: frame as drift you found ("the spec says X, but the code does Y — which is current?"). In evolve: frame as gaps the new scope opens.
6. **Rewrite the body in place** — under the snapshot gate (Core Principle #3). In reconcile: correct the description so it states the change accurately as built; fix altitude and consistency; scope unchanged. In evolve: fold the new scope into the body as target design, alongside the existing scope (all stated as current design, never as history). Keep the spec at its existing path; do not rename or re-date. Commit.
7. **Spec self-review** — including the snapshot check (below).
8. **User reviews the updated spec** — ask the user to review.
9. **Transition** — branches by intent (terminals below).

## Reconcile Mode

Posture: **make the description match reality, scope unchanged.**

- Compare each section against what was built. Where they differ, decide which is current (ask if unclear) and rewrite the section to state the change accurately as built.
- Fix altitude drift and internal consistency the same way `spec-brainstorming` review does — but you are reconciling to *built* reality, not refining a design from scratch.
- **Nothing built yet?** If the spec is `in_progress` with no executed plan, there is nothing to reconcile against — tell the user, and limit the pass to altitude/consistency fixes only (or route to `spec-brainstorming` if the design itself needs rethinking).
- **Status: unchanged.** No plan. **Terminal:** after the user reviews, commit and stop. Do NOT invoke `writing-plans`.

## Evolve Mode

Posture: **grow the change's scope, then plan what isn't yet built.**

- Clarifying questions one at a time on the new/changed scope; defer what can't be settled to Open Questions (append-only, never delete).
- Rewrite the body to include the new scope as target design, next to the existing scope — all present-tense current design, at design altitude (per-task detail goes to the plan), no "added later" / "now also" revision narration.
- **Hand `writing-plans` the scope that still needs a plan** — it depends on the entry status:
  - **`implemented`** (plan fully executed): hand only the **delta** — new tasks for the new/changed scope. The existing plan stays; tell writing-plans *"plan only this delta; the existing scope is already implemented."*
  - **`in_progress`**: hand writing-plans the new scope **plus any base scope not yet executed**. If a plan exists and is partially executed, append the delta to it; if no plan exists yet, writing-plans plans the whole spec. Tell writing-plans *"existing executed scope stays; plan the rest."*
- **Status:** evolve on `implemented` flips `implemented → in_progress` (re-opened); evolve on `in_progress` leaves it `in_progress`. **Terminal:** invoke `writing-plans`. Do NOT invoke any other skill. After the new scope is executed, `finishing-a-development-branch` re-sets `implemented`.

## Spec Self-Review

After rewriting the body, look at it with fresh eyes. Run the standard checks — status correctness, Open Questions integrity, template conformance, code leakage, placeholder scan, internal consistency, scope, ambiguity — **and** the snapshot checks:

1. **Revision-log scan:** search the body for revision-log tokens — e.g. `Deleted:`, `Removed:`, `Changed:`, `Updated:`, `Previously:`, `Old:`, `New:`, `Replaced`, `Migrated`, `was →`, `~~strikethrough~~`, and edit-dates or before/after framing. The list is exemplary, not exhaustive — the real test is *"is this narrating a revision to the document?"* Any hit is a failure: rewrite that span as a flat, present-tense statement of the target design of the change. The body describes the change; it is not a changelog of itself.
2. **Before/after framing:** any "originally X, now Y" or strikethrough narration → flatten to the current target design.
3. **Altitude:** per-task detail a human would skim rather than review belongs in the plan. Push it down; do not grow the spec.
4. **Reality match (reconcile):** does every reconciled section now match what was built? No invented behavior.

*(Open Questions' checked items carry resolution + date by design — those are decision records, not document revisions; the scan above does not flag them. No other section is exempt — do not invent a "Notes"/"History"/"Change Log" section to park revision narration.)*

Fix issues inline. No need to re-review — just fix and move on.

## Status Transitions This Skill Writes

- Reconcile: **none** (status unchanged).
- Evolve on `implemented`: `implemented → in_progress`.
- Evolve on `in_progress`: stays `in_progress`.
- This skill **never** sets `implemented` or `released` — those are `finishing-a-development-branch`'s.

## User Review Gate

After the self-review passes:

> "Spec updated and committed to `<path>` (Status: <status>, <reconcile|evolve>). Please review it before we move on."

Wait for the response. If they request changes, make them and re-run the self-review. Only proceed to the terminal once they approve.

## Process Flow

```dot
digraph spec_update {
    rankdir=TB;
    "Determine intent" [shape=diamond];
    "Load spec + plan + built reality" [shape=box];
    "RECONCILE: rewrite body\nto match built reality" [shape=box];
    "EVOLVE: fold new scope into body\n(snapshot gate)" [shape=box];
    "Self-review + user review" [shape=box];
    "Entry status?" [shape=diamond];
    "Status: unchanged" [shape=box];
    "implemented → in_progress" [shape=box];
    "in_progress (unchanged)" [shape=box];
    "writing-plans (delta / remaining scope)" [shape=doublecircle];
    "Commit + stop" [shape=doublecircle];

    "Determine intent" -> "Load spec + plan + built reality";
    "Load spec + plan + built reality" -> "RECONCILE: rewrite body\nto match built reality" [label="reconcile"];
    "Load spec + plan + built reality" -> "EVOLVE: fold new scope into body\n(snapshot gate)" [label="evolve"];
    "RECONCILE: rewrite body\nto match built reality" -> "Self-review + user review";
    "EVOLVE: fold new scope into body\n(snapshot gate)" -> "Self-review + user review";
    "Self-review + user review" -> "Status: unchanged" [label="reconcile"];
    "Status: unchanged" -> "Commit + stop";
    "Self-review + user review" -> "Entry status?" [label="evolve"];
    "Entry status?" -> "implemented → in_progress" [label="implemented"];
    "Entry status?" -> "in_progress (unchanged)" [label="in_progress"];
    "implemented → in_progress" -> "writing-plans (delta / remaining scope)";
    "in_progress (unchanged)" -> "writing-plans (delta / remaining scope)";
}
```

**Terminal state.** Reconcile ends at a committed spec, status unchanged, no plan. Evolve ends at `writing-plans`: on an `implemented` spec it flips `implemented → in_progress` and plans only the delta; on an `in_progress` spec the status is unchanged and writing-plans covers the new scope plus any un-executed base scope. Code is written only by the plan's implementer — never here.

## Custom Spec Template

Same fit-check protocol as `spec-brainstorming`: if `docs/superpowers/spec-template.md` exists, map the updated design onto it and surface every mismatch in one batched message before deviating. A `Status` line and an `## Open Questions` section are expected; add them if missing.
