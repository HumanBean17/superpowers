# Custom Spec Templates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional, opt-in custom spec templates to the `brainstorming` skill so written specs follow a user-supplied structure, with a one-shot deviation ask when a task doesn't fit that structure.

**Architecture:** Pure opt-in. A `spec-template.md` placed beside `SKILL.md` is read at spec-writing time (present → structure the spec around it; absent → freeform, zero behavior change). All detail (format, fit-check procedure, deviation-ask script, worked example) lives in a new sibling guide `custom-spec-templates.md`; `SKILL.md` gets only one new checklist step + one short subsection. A Bash regression test (mirroring `tests/claude-code/test-worktree-path-policy.sh`) guards the opt-in contract. No runtime code — only markdown + a grep-based test.

**Tech Stack:** Markdown (skill content), graphviz `dot` (the checklist diagram inside `SKILL.md`), Bash (regression test).

**Spec:** `docs/superpowers/specs/2026-07-02-custom-spec-templates-design.md`

---

## File Structure

- **Create** `skills/brainstorming/custom-spec-templates.md` — sibling guide: opt-in rule, template format + `[required]` tag, the three fit-check buckets, the deviation-ask script, worked example. Single responsibility: everything an author/implementer needs to know about templates, kept out of `SKILL.md`.
- **Create** `tests/claude-code/test-spec-template-opt-in.sh` — regression test asserting the opt-in contract (no template ships; guide exists; `SKILL.md` references both files and has the fit-check step; guide documents `[required]` and the no-code rule).
- **Modify** `skills/brainstorming/SKILL.md` — (1) insert checklist step 7 "Template fit check" and renumber 7–10 → 8–11; (2) add one node + one edge to the process-flow graph; (3) add a short `## Custom Spec Template` subsection before `## Key Principles`.
- **Deliberately NOT created** `skills/brainstorming/spec-template.md` — pure opt-in; no template ships. The regression test asserts its absence.

**Working-tree note:** `skills/brainstorming/SKILL.md` already has uncommitted edits in the working tree (the "Context before code" / "Specs carry design, not code" core principles). The edits below apply **on top of** that state. Do not revert that WIP.

---

## Task 0: Isolate the work on a feature branch

**Files:** none

- [ ] **Step 1: Create a feature branch from current HEAD**

The repo currently sits on `main` with uncommitted `SKILL.md` edits. Carry them onto a branch.

```bash
git checkout -b feat/custom-spec-templates
git status
```

Expected: `On branch feat/custom-spec-templates`; `skills/brainstorming/SKILL.md` still listed as modified (the WIP rides along).

- [ ] **Step 2: Confirm starting state**

```bash
test ! -f skills/brainstorming/custom-spec-templates.md && echo "guide absent (expected)"
test ! -f skills/brainstorming/spec-template.md && echo "no shipped template (expected)"
grep -c "Template fit check" skills/brainstorming/SKILL.md || echo "0 (expected: step not added yet)"
```

Expected: both "absent/expected" lines print, and the grep count prints `0` (no match yet).

---

## Task 1: Write the regression test (RED)

**Files:**
- Create: `tests/claude-code/test-spec-template-opt-in.sh`

- [ ] **Step 1: Create the test file**

Model it on `tests/claude-code/test-worktree-path-policy.sh` (same `set -euo pipefail`, `REPO_ROOT` derivation, `assert_contains` helper style, `STATUS: PASSED/FAILED` tail).

````bash
cat > tests/claude-code/test-spec-template-opt-in.sh <<'EOF'
#!/usr/bin/env bash
# Regression check: brainstorming skill supports custom spec templates as pure
# opt-in. No spec-template.md ships by default; the feature is documented in a
# sibling guide that SKILL.md points to; the [required] convention and the
# no-code-in-spec rule are documented.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BRAINSTORM="$REPO_ROOT/skills/brainstorming"
SKILL_MD="$BRAINSTORM/SKILL.md"
GUIDE="$BRAINSTORM/custom-spec-templates.md"

failures=0

assert_contains() {
    local file="$1" pattern="$2" label="$3"
    if grep -Fq "$pattern" "$file"; then
        echo "  [PASS] $label"
    else
        echo "  [FAIL] $label"
        echo "    Expected to find: $pattern"
        echo "    In file: $file"
        failures=$((failures + 1))
    fi
}

assert_file_exists() {
    local file="$1" label="$2"
    if [ -f "$file" ]; then
        echo "  [PASS] $label"
    else
        echo "  [FAIL] $label"
        echo "    Expected file to exist: $file"
        failures=$((failures + 1))
    fi
}

assert_file_absent() {
    local file="$1" label="$2"
    if [ -f "$file" ]; then
        echo "  [FAIL] $label"
        echo "    Did not expect file to ship: $file"
        failures=$((failures + 1))
    else
        echo "  [PASS] $label"
    fi
}

echo "=== Custom Spec Template Opt-In Test ==="
echo ""

# Pure opt-in: no default template ships.
assert_file_absent "$BRAINSTORM/spec-template.md" "no spec-template.md ships by default"

# The sibling guide exists and SKILL.md points to it.
assert_file_exists "$GUIDE" "custom-spec-templates.md guide exists beside SKILL.md"
assert_contains "$SKILL_MD" "custom-spec-templates.md" "SKILL.md references the guide"
assert_contains "$SKILL_MD" "spec-template.md" "SKILL.md references the user template file"

# The fit check is part of the brainstorming flow.
assert_contains "$SKILL_MD" "Template fit check" "SKILL.md has the Template fit check step"

# The [required] convention and the no-code rule are documented in the guide.
assert_contains "$GUIDE" "[required]" "guide documents the [required] tag"
assert_contains "$GUIDE" "not implementation code" "guide preserves the no-code-in-spec rule"

echo ""

if [ "$failures" -gt 0 ]; then
    echo "STATUS: FAILED ($failures failures)"
    exit 1
fi

echo "STATUS: PASSED"
EOF
````

- [ ] **Step 2: Make it executable**

```bash
chmod +x tests/claude-code/test-spec-template-opt-in.sh
```

- [ ] **Step 3: Run it and confirm it FAILS for the right reasons**

```bash
bash tests/claude-code/test-spec-template-opt-in.sh
```

Expected: `STATUS: FAILED` with these failures (the contract isn't implemented yet):
- `[FAIL] custom-spec-templates.md guide exists beside SKILL.md`
- `[FAIL] SKILL.md references the guide`
- `[FAIL] SKILL.md references the user template file`
- `[FAIL] SKILL.md has the Template fit check step`
- `[FAIL] guide documents the [required] tag`
- `[FAIL] guide preserves the no-code-in-spec rule`

And these should already PASS:
- `[PASS] no spec-template.md ships by default`

Do not commit yet — the test goes green in Task 3 and is committed in Task 4.

---

## Task 2: Create the sibling guide

**Files:**
- Create: `skills/brainstorming/custom-spec-templates.md`

- [ ] **Step 1: Write the guide**

This file holds all template detail so `SKILL.md` stays lean. It uses 4-space-indented code blocks (not fenced) so the example renders without fence conflicts.

````markdown
cat > skills/brainstorming/custom-spec-templates.md <<'EOF'
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
EOF
````

- [ ] **Step 2: Run the test — guide assertions now pass, SKILL.md ones still fail**

```bash
bash tests/claude-code/test-spec-template-opt-in.sh
```

Expected: still `STATUS: FAILED`, but these now PASS:
- `[PASS] custom-spec-templates.md guide exists beside SKILL.md`
- `[PASS] guide documents the [required] tag`
- `[PASS] guide preserves the no-code-in-spec rule`

Still failing (SKILL.md not wired yet):
- `[FAIL] SKILL.md references the guide`
- `[FAIL] SKILL.md references the user template file`
- `[FAIL] SKILL.md has the Template fit check step`

---

## Task 3: Wire SKILL.md (GREEN)

**Files:**
- Modify: `skills/brainstorming/SKILL.md` (checklist ~lines 36–40, graph ~lines 49 & 60, new subsection before `## Key Principles`)

- [ ] **Step 1: Insert the new checklist step and renumber**

Find this block in `skills/brainstorming/SKILL.md`:

```markdown
6. **Present design** — in sections scaled to their complexity, get user approval after each section
7. **Write design doc** — save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commit
8. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope (see below)
9. **User reviews written spec** — ask user to review the spec file before proceeding
10. **Transition to implementation** — invoke writing-plans skill to create implementation plan
```

Replace with:

```markdown
6. **Present design** — in sections scaled to their complexity, get user approval after each section
7. **Template fit check** — if `spec-template.md` exists beside this skill, map the approved design onto it; surface every mismatch in one message and ask before deviating. Skip if absent. See Custom Spec Template.
8. **Write design doc** — save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commit
9. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope (see below)
10. **User reviews written spec** — ask user to review the spec file before proceeding
11. **Transition to implementation** — invoke writing-plans skill to create implementation plan
```

- [ ] **Step 2: Add the fit-check node to the process-flow graph**

Find this declaration (inside the `digraph brainstorming {` block):

```dot
    "User approves design?" [shape=diamond];
    "Write design doc" [shape=box];
```

Replace with:

```dot
    "User approves design?" [shape=diamond];
    "Template fit check" [shape=box];
    "Write design doc" [shape=box];
```

Then find this edge:

```dot
    "User approves design?" -> "Write design doc" [label="yes"];
```

Replace with:

```dot
    "User approves design?" -> "Template fit check" [label="yes"];
    "Template fit check" -> "Write design doc";
```

- [ ] **Step 3: Add the short subsection before `## Key Principles`**

Find the `## Key Principles` heading and insert this section immediately above it:

```markdown
## Custom Spec Template

Specs are freeform by default. To enforce a structure, place a `spec-template.md` beside this `SKILL.md`; when present the agent writes the spec to that structure, when absent nothing changes. The template is a markdown outline of sections, each a suggestion unless its heading is suffixed `[required]`. After the design is approved and before writing the spec, the agent maps the design onto the template and, for any `[required]` section that doesn't apply, section the task needs but the template lacks, or conflicting guidance, lists every mismatch in one message and asks before deviating. Dropping a non-required section needs no ask, and the template affects only the written spec — never the brainstorming conversation. Format, the full procedure, and a worked example are in `custom-spec-templates.md`.
```

- [ ] **Step 4: Run the regression test — expect GREEN**

```bash
bash tests/claude-code/test-spec-template-opt-in.sh
```

Expected: every line `[PASS]`, ending in `STATUS: PASSED`.

- [ ] **Step 5: Commit the feature content (guide + SKILL.md)**

```bash
git add skills/brainstorming/custom-spec-templates.md skills/brainstorming/SKILL.md
git commit -m "feat(brainstorming): add optional custom spec templates

Pure opt-in: a spec-template.md beside SKILL.md structures the written spec;
absent, behavior is unchanged. When a task doesn't fit, the agent surfaces every
mismatch in one message and asks before deviating. Detail lives in a new sibling
guide custom-spec-templates.md; SKILL.md gains one checklist step and a short
subsection."
```

Note: this commit intentionally excludes the test (committed separately in Task 4), so each commit is green on its own.

---

## Task 4: Register and commit the regression test

**Files:**
- Modify: `tests/claude-code/run-skill-tests.sh` (the `tests=()` array, ~line 75)

- [ ] **Step 1: Add the new test to the runner's array**

Find this in `tests/claude-code/run-skill-tests.sh`:

```bash
tests=(
    "test-worktree-path-policy.sh"
    "test-sdd-workspace.sh"
    "test-subagent-driven-development.sh"
)
```

Replace with:

```bash
tests=(
    "test-worktree-path-policy.sh"
    "test-sdd-workspace.sh"
    "test-subagent-driven-development.sh"
    "test-spec-template-opt-in.sh"
)
```

- [ ] **Step 2: Re-run the test directly — confirm still GREEN**

```bash
bash tests/claude-code/test-spec-template-opt-in.sh
```

Expected: `STATUS: PASSED`.

- [ ] **Step 3: Commit the test + runner registration**

```bash
git add tests/claude-code/test-spec-template-opt-in.sh tests/claude-code/run-skill-tests.sh
git commit -m "test(brainstorming): assert spec-template opt-in contract

Mirrors test-worktree-path-policy.sh. Asserts no spec-template.md ships by
default, the custom-spec-templates.md guide exists beside SKILL.md, SKILL.md
references both files and has the Template fit check step, and the guide
documents the [required] tag and the no-code-in-spec rule."
```

---

## Task 5: Behavioral acceptance (manual / eval gate)

This is the non-unit verification. Skill behavior can't be asserted with grep — per `CLAUDE.md` ("Skill Changes Require Evaluation"), confirm the behavior in real sessions before relying on it. `evals/` is not cloned in this fork, so run these as manual Claude Code sessions and record results.

**Files:** none (verification only)

- [ ] **Step 1: Scenario A — required section that doesn't apply triggers the ask**

Create a throwaway template with a required section that won't fit a trivial task:

```bash
cp skills/brainstorming/SKILL.md /tmp/SKILL.md.bak 2>/dev/null || true
cat > skills/brainstorming/spec-template.md <<'EOF'
# Spec

## Overview
What this is and why.

## API Contract [required]
JSON Schema or signature for any external surface.
EOF
```

In a fresh Claude Code session in this repo, send: `Let's brainstorm renaming a single local variable in a README.`

Expected: after design approval and before the spec is written, the agent runs the fit check and sends **one** message noting `[required] 'API Contract'` doesn't apply and asking whether it's OK to omit — rather than silently dropping it or forcing a fake API section.

Record the outcome (pass/fail + the agent's actual message) in `docs/superpowers/specs/2026-07-02-custom-spec-templates-design.md` under a new `## Acceptance Results` section, or in a follow-up note.

Clean up:

```bash
rm -f skills/brainstorming/spec-template.md
bash tests/claude-code/test-spec-template-opt-in.sh   # still PASSED (template removed)
```

- [ ] **Step 2: Scenario B — no template means unchanged behavior**

With no `spec-template.md` present (the default), start a fresh session and send: `Let's make a react todo list.`

Expected: the normal brainstorming flow runs; no fit-check message appears; the spec is freeform. Behavior is identical to before the change.

- [ ] **Step 3: Scenario C — task needs a section the template lacks**

Restore the Scenario A template, then in a fresh session brainstorm something that needs an extra section, e.g.: `Let's brainstorm adding a database migration to backfill user display names.`

Expected: the fit check fires a "Needed-missing" item (e.g. a migration section) and asks before adding it.

Clean up the template again:

```bash
rm -f skills/brainstorming/spec-template.md
```

- [ ] **Step 4: Commit acceptance results**

If you recorded results in the spec or a note:

```bash
git add docs/superpowers/specs/2026-07-02-custom-spec-templates-design.md
git commit -m "docs(brainstorming): record custom spec template acceptance results"
```

If any scenario failed, do not mark this plan complete — open a follow-up to revise the skill wording and re-run.

---

## Task 6: Full verification and size check

**Files:** none (verification only)

- [ ] **Step 1: Run the new test directly (no `claude` CLI dependency)**

```bash
bash tests/claude-code/test-spec-template-opt-in.sh
```

Expected: `STATUS: PASSED`.

- [ ] **Step 2: Run the broader skill test suite (requires `claude` CLI)**

If `claude` is installed:

```bash
bash tests/claude-code/run-skill-tests.sh
```

Expected: `Passed: 4`, `Failed: 0`, `STATUS: PASSED` (the three pre-existing tests plus the new one).

If `claude` is not installed, the runner aborts at its CLI check — that's expected; the direct invocation in Step 1 is the authoritative gate for this change.

- [ ] **Step 3: Confirm no template ships and the size delta is in range**

```bash
test ! -f skills/brainstorming/spec-template.md && echo "OK: no shipped template"
wc -l skills/brainstorming/SKILL.md
```

Expected: `OK: no shipped template`, and a line count around **177** (was 169; +8 ≈ +5%). Word count should land near **~1,900** (was 1,731). If `SKILL.md` grew beyond ~185 lines, trim the subsection.

- [ ] **Step 4: Final status**

```bash
git status
git log --oneline -5
```

Expected: clean working tree (aside from any deliberately preserved WIP), with the feature and test commits on `feat/custom-spec-templates` on top of the prior WIP.

---

## Self-Review

**1. Spec coverage** — each spec requirement maps to a task:
- Discovery (single sibling `spec-template.md`, opt-in) → Task 2 guide "Opt-in"; guarded by Task 1 `assert_file_absent` + the guide's text.
- Template format (outline + `[required]`, no-code rule) → Task 2 guide "Template format"; guarded by `assert_contains "[required]"` and `"not implementation code"`.
- Fit-check procedure (three buckets, after design approval, before writing spec) → Task 2 guide "The fit check" + Task 3 checklist step 7.
- Deviation ask (one batched message, approve/adjust) → Task 2 guide "The deviation ask".
- Wiring (sibling guide + SKILL.md trigger, lean) → Tasks 2 & 3; size guard in Task 6 Step 3.
- Non-goals (no plan templates, no reviewer-prompt change, no shipped default) → honored: only `custom-spec-templates.md` + `SKILL.md` touched; `spec-document-reviewer-prompt.md` untouched; absence asserted.
- Verification (3 scenarios) → Task 5.
- Working-tree WIP caveat → Task 0 note + Task 6 Step 4.

No spec section is unaccounted for.

**2. Placeholder scan** — no TBD/TODO/"add appropriate handling"/"similar to Task N". Every content step includes the full text to write; every command includes expected output. The only intentionally conditional steps are the `claude`-CLI-dependent ones in Task 6 (explicitly flagged) and the manual sessions in Task 5 (behavioral by nature).

**3. Consistency** — the string `Template fit check` is identical across the checklist (Task 3 Step 1), the graph node (Task 3 Step 2), and the test assertion (Task 1). The filenames `spec-template.md` and `custom-spec-templates.md` are spelled identically everywhere they appear. `[required]` tag syntax is consistent across guide, example, and test assertion.

No issues found; no inline fixes needed.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-02-custom-spec-templates.md`. Two execution options:

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration. REQUIRED SUB-SKILL: superpowers:subagent-driven-development.
2. **Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints. REQUIRED SUB-SKILL: superpowers:executing-plans.

Which approach?
