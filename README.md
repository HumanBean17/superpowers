# Superpowers

Superpowers is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.

## Changes from Original Superpowers

This fork makes several intentional modifications to the original superpowers framework ideology and workflow:

### Brainstorming Runs Proactively; Specs Are Opt-In

The **brainstorming skill is proactively executed for any creative work**, including small tasks — it explores intent, proposes approaches, and presents a design for approval before any code is written. This matches the original framework's mandatory trigger.

The change from the original is narrower: **writing a spec document is now optional.** Once the design is approved, the agent asks whether to formalize it into a spec. Decline it and you go straight to implementation; accept it and the usual spec → plan → implementation flow follows.

**Rationale:** The brainstorming conversation catches unexamined assumptions early, even on simple tasks — so it stays proactive. But not every task needs a committed spec file, so spec generation is opt-in rather than forced.

### Spec-Brainstorming: Two-Round Spec Lifecycle

A new **spec-brainstorming** skill adds a two-round spec lifecycle for teams with a system analyst and a developer. Round 1 (analyst, build) turns an idea into a `Status: draft` spec and stops — no plan, no code. Round 2 (developer, review) walks the draft top-down, refines it, resolves or accepts its Open Questions, and either leaves it as `draft` or approves it to `Status: in_progress` and hands off to `writing-plans`. Both rounds share one design-thinking core and a structured **Open Questions** section; detailization depth is never role-gated.

**Rationale:** The original `brainstorming` skill stays proactive for general creative work; `spec-brainstorming` is opt-in, invoked only when a spec build/review round is explicitly requested.

### Spec Lifecycle: Four Statuses + a spec-update Skill

The spec `Status` field grows from two values (`draft`, `in_progress`) to four: **`draft` → `in_progress` → `implemented` → `released`**. `implemented` marks a spec whose plan is executed and tests are green but not yet merged; `released` is terminal, set when the change merges and the spec archives as an ADR. `finishing-a-development-branch` writes both (`implemented` at green tests, `released` at archive), so a spec is never archived while `in_progress`.

A new opt-in **spec-update** skill (sibling to spec-brainstorming) reconciles or evolves an existing `in_progress`/`implemented` spec. **Reconcile** rewrites the body to match built reality (scope unchanged, no plan); **evolve** folds in new scope and hands only the **delta** to writing-plans (`implemented → in_progress`), then executes just the delta — the workflow is not waterfall. Both run under a **snapshot gate**: the body describes one change to the system, rewritten in place, never a changelog of itself (no `Deleted:`/`Changed:`/before-after); the document's history is git + the archived ADR. Drafts stay in spec-brainstorming, which gains the same snapshot principle and self-review check. The regular `brainstorming` skill now writes a `Status` line and promotes `draft → in_progress` before handing off, and `writing-plans` honors a delta request (plans only new scope) when re-invoked by spec-update.

**Rationale:** Real work needs changes after a spec and plan are implemented, but ad-hoc prompt edits corrupted specs — agents treated them as logs and drifted the detailization level. Explicit terminal/implemented statuses plus a protected update skill with the snapshot gate keep specs honest across the whole non-waterfall lifecycle.

### Custom Spec Templates

Support for **project-level custom spec templates** has been added. If you create a `docs/superpowers/spec-template.md` file in your project, the brainstorming skill will use it as a template for writing design specs. Templates use a `[required]` suffix to mark mandatory sections.

**Rationale:** Projects often have specific documentation standards. This allows teams to enforce consistent spec structure without modifying the core skill.

### Visual Companion Removed

The browser-based **visual companion feature** (mockups, diagrams, visual options) has been removed from the brainstorming skill.

**Rationale:** The feature was complex, token-intensive, and not widely used. The brainstorming conversation remains fully text-based.

### Writing-Skills Skill Removed

The **writing-skills skill** (for creating new skills) has been removed entirely.

**Rationale:** Skill authoring is now documented directly in the contribution guidelines rather than through a separate skill.

### Strengthened "Specs Carry Design, Not Code"

The brainstorming skill now more strongly enforces the principle that **design specs should not contain implementation code**. Specs describe WHAT to build and WHY, with references to classes, methods, and contracts — but method bodies, algorithms, and actual code belong in the implementation phase.

**Rationale:** This separation keeps specs focused on design and prevents implementation details from creeping into the design phase.

### Spec Altitude: Human-Reviewed Spec, Agent-Facing Plan

The `brainstorming` and `spec-brainstorming` skills now state an explicit abstraction-level calibration: the **spec is the human's review surface**, kept at design altitude (components, contracts, decisions); the **plan is the agent-facing artifact** that carries per-task detail (what one task needs to be written, not the design itself). The spec template sets the spec's sections; this governs only the altitude of what goes in them. When a section sprawls into per-task detail a human would skim rather than review, the guidance is to push that down into the plan — not grow the spec, never write code in it. A new self-review "Altitude check" enforces this; a lower bound keeps the spec concrete enough (named components, contracts, key decisions) that a plan agent can still expand it into tasks.

**Rationale:** Specs had drifted toward implementation detail humans couldn't usefully review. The plan is already the designated home for per-task design — `writing-plans`' "plans carry design, not code" mirrors the spec's rule — so the fix is to route that detail there, not bloat the spec or leak code.

### Code Review Fans Out a Team

The **requesting-code-review** skill dispatches a **team of reviewer subagents in parallel** — one per review scope — instead of a single reviewer. The agent inspects the diff and decides the scope breakdown (by subsystem, concern, or file cluster); there is no fixed set of roles. Findings from all reviewers are merged and deduped before you act on them.

**Rationale:** Several focused reviewers each holding a small slice cover more ground than one reviewer juggling the entire diff, and each reviewer's isolated context stays small.

### Define-and-Execute: Fast Path for Fully-Specified Tasks

A new **define-and-execute** skill handles tasks that need no creative work — the goal and testable success criteria are stated up front. The agent acts as an orchestrator: it runs a Validate gate (restates the goal, scores each criterion against a testability rubric, enumerates every unstated decision and stops to batch-ask if anything is missing), executes via **subagent-driven-development** (skipping brainstorming and writing-plans), and returns an **evidence report** that proves each criterion with concrete pasted outputs (requests, responses, database rows, logs) — not "tests pass". It stops and asks — never fabricates — on an unclear goal, an untestable criterion, an unstated decision, a blocker, or intent divergence.

**Rationale:** The full brainstorming → writing-plans → executing flow is right when design is open, but some tasks are already fully specified and only need rigorous execution plus proof. `autonomous-executor` covers the "step away and deliver, decide-and-note" case; `define-and-execute` covers the "fully specified, but stop and ask on anything unstated" case. The two coexist as different ambiguity postures.

### Upstream Sync — v6.2.0 (synced 2026-08-05)

Last synced with upstream [obra/superpowers](https://github.com/obra/superpowers) through commit **`44c9b2d`** (2026-07-28, "docs: remove the 'We're Hiring' section"), one commit past tag **`v6.2.0`** (`3dcbd5c`, 2026-07-23). Fork point: `v6.1.0` (`f268f7c`).

The sync is **selective**, not a full merge — most of the 62 upstream commits are Codex/Gemini/hook work this fork removed on purpose. What was taken:

- **Clean wins (no conflict):** upstream's `writing-good-tests.md` reference (replaces `testing-anti-patterns.md`); the validated skills "compression sweep" (drop recap/social-proof/persuasion prose) on the skills this fork never modified; `find-polluter.sh` `./`-prefix fix.
- **SDD execution engine:** the v6.2.0 plan-scoped workspace + resume-based fix loop adopted into `subagent-driven-development` — the engine `define-and-execute` already delegates to. Complements (does not overlap) this fork's spec-brainstorming / define-and-execute layer.
- **Validated cuts ported into the rewritten skills:** `finishing-a-development-branch` (worktree-path bug fix, discard-as-explicit-request, rationalization table), `writing-plans` (dropped "Remember" recap), `requesting-code-review` (rationalization table), `brainstorming` and `spec-brainstorming` (folded "Key Principles" recap into points of use — `spec-brainstorming` is a brainstorming clone and got the same treatment for consistency).

**Deliberately skipped:** all Codex portal packaging and the v6.1.1 Codex release; the re-added Gemini CLI support; Windows/hook work — none of which this fork carries. The fork's no-Gemini platform footprint is preserved (the re-added "Gemini CLI" mention was stripped from `executing-plans`).

**Fork customizations preserved on top of upstream:** the "plans carry design, not code" model-tier guidance in `subagent-driven-development`; the `docs/superpowers/plans/active/` path convention; the spec/plan archive step in `finishing-a-development-branch`; the parallel-reviewer fan-out in `requesting-code-review`.

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Fans out a team of reviewers (one per scope, in parallel), merges findings, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

**Alternative entry point — define-and-execute:** For fully-specified tasks (goal + testable success criteria, no design work), skip steps 1 and 3 (brainstorming and writing-plans) and use **define-and-execute**. It validates the criteria, executes via subagent-driven-development, and returns an evidence report proving each criterion. It stops and asks rather than improvising; it never decides-and-notes an unstated decision (that is `autonomous-executor`'s job).

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **spec-brainstorming** - Two-round spec lifecycle (analyst build → developer review); opt-in
- **spec-update** - Reconcile/evolve an existing in_progress/implemented spec (snapshot-gated; delta plan for new scope)
- **define-and-execute** - Fast path for fully-specified tasks: validate goal+criteria, execute via subagents, return an evidence report; stops and asks on anything unstated
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Fan-out review team (one reviewer per scope)
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **using-superpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

Read [the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/).
