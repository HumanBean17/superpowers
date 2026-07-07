# Superpowers

Superpowers is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.

## Changes from Original Superpowers

This fork makes several intentional modifications to the original superpowers framework ideology and workflow:

### Brainstorming Runs Proactively; Specs Are Opt-In

The **brainstorming skill is proactively executed for any creative work**, including small tasks — it explores intent, proposes approaches, and presents a design for approval before any code is written. This matches the original framework's mandatory trigger.

The change from the original is narrower: **writing a spec document is now optional.** Once the design is approved, the agent asks whether to formalize it into a spec. Decline it and you go straight to implementation; accept it and the usual spec → plan → implementation flow follows.

**Rationale:** The brainstorming conversation catches unexamined assumptions early, even on simple tasks — so it stays proactive. But not every task needs a committed spec file, so spec generation is opt-in rather than forced.

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

### Code Review Fans Out a Team

The **requesting-code-review** skill dispatches a **team of reviewer subagents in parallel** — one per review scope — instead of a single reviewer. The agent inspects the diff and decides the scope breakdown (by subsystem, concern, or file cluster); there is no fixed set of roles. Findings from all reviewers are merged and deduped before you act on them.

**Rationale:** Several focused reviewers each holding a small slice cover more ground than one reviewer juggling the entire diff, and each reviewer's isolated context stays small.

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Fans out a team of reviewers (one per scope, in parallel), merges findings, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
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

## Contributing

The general contribution process for Superpowers is below. Keep in mind that we don't generally accept contributions of new skills and that any updates to skills must work across all of the coding agents we support.

1. Fork the repository
2. Switch to the 'dev' branch
3. Create a branch for your work
4. Submit a PR, being sure to fill in the pull request template.

Skill-behavior tests use the drill eval harness from [superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/), cloned into `evals/` — see `evals/README.md` for setup. Plugin-infrastructure tests live at `tests/` and run via the relevant `run-*.sh` or `npm test`.
