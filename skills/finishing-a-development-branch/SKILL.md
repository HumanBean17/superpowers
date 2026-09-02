---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch

## Overview

**Core principle:** Verify tests → mark spec `implemented` → Detect environment → Present options → Execute choice → Archive released specs/plans (set `Status: released`) → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## Step 1: Verify Tests

Run the project's full test suite (`npm test` / `cargo test` / `pytest` / `go test ./...`).

**If tests fail**, report the failures and stop — the menu comes after a green suite:

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]
```

**If tests pass:** the plan is fully executed and the code is complete. Find the work's spec under `docs/superpowers/specs/active/` — a single `…-design.md` file, or a modular spec as a directory containing `00-index.md` — and set its status (edit the file, or `00-index.md` for a modular spec):
- `in_progress` → set to `implemented` (the "done but not yet released" state) and commit.
- already `implemented`/`released` → leave it.
- `draft` (or no `Status` line — treat as `draft`) → the spec was **never approved**. Leave its status unchanged and tell the user; do not promote it. (A draft must be approved via `spec-brainstorming` before it can be released.)
- no spec → skip.

Then continue to Step 2.

## Step 2: Detect Environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# Capture now, while still inside the workspace — Step 5 changes directory
# before cleanup (Step 6) needs this value
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

This determines which menu to show and how cleanup works:

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 3 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 3 options | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 2 options (no merge) | Externally managed — leave in place |

## Step 3: Determine Base Branch

The base branch is whatever this work forked from — usually named in the
plan, the conversation, or the branch's upstream. If it is not already
known, ask: "This branch split from <your best guess> - is that correct?"
Confirm before merging: merging into the wrong base is expensive to undo.

## Step 4: Present Options

**Normal repo and named-branch worktree — present exactly these 3 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Which option?
```

**Detached HEAD — present exactly these 2 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Which option?
```

Present the menu exactly as written — concise, with every option coming
from the list above. Discarding the work happens only in response to your
human partner explicitly asking for it (see "If your human partner asks to
discard the work" below). Wait for their answer; the integration decision
is theirs.

## Step 5: Execute Choice

### Option 1: Merge Locally

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>
```

If tests fail on the merged result: stop, leave the worktree and branch in
place, and investigate — nothing has been pushed, so the merge is local
and recoverable.

Once the merged result is green: clean up the worktree (Step 6), then
delete the branch:

```bash
git branch -d <feature-branch>
```

**Archive the released spec & plan (ADR transition).** The change is now in `<base-branch>`, so its spec and plan are no longer current source of truth. Set each archived spec's `Status` line to `released` — its terminal state — **only if it is `implemented`** (set in Step 1); for a modular spec the `Status` line is in `00-index.md`. Skip any spec still at `draft` (never approved): leave it in `active/` and tell the user to approve or discard it. Then move the released specs and their plans from `active/` to `archive/`, where they become ADRs — a historical record of a past decision, not a description of current domain state:

```bash
mkdir -p docs/superpowers/specs/archive docs/superpowers/plans/archive
# The spec(s) and plan(s) this branch implemented.
# Set each spec's Status to 'released' (terminal) first — use your edit tool, not a shell command:
#   single-file spec → edit the Status line in its .md file;  modular spec → edit it in 00-index.md.
# Guard each move on existence: a spec-only change (e.g. define-and-execute) may have no plan — skip the plan move if absent.
# If more than one is active, ask your human partner which to archive before moving.
# <spec-name> is the spec's entry under active/ — either <topic>-design.md (single file) or <topic>/ (modular directory); git mv moves either.
git mv docs/superpowers/specs/active/<spec-name> docs/superpowers/specs/archive/
git mv docs/superpowers/plans/active/<plan>.md docs/superpowers/plans/archive/
git commit -m "docs: archive spec/plan for <feature> (released → ADR)"
```

Domain reference files under `docs/superpowers/domain/` are current domain state, not decision records — never archive them with a released spec. Specs link to them; the next spec touching the same domain reuses them.

If no spec/plan exists under `active/` (e.g., this branch had none), skip this step silently.

### Option 2: Push and Create PR

```bash
git push -u origin <feature-branch>
# From a detached HEAD, name the new branch on the remote:
# git push origin HEAD:refs/heads/<new-branch>
```

Then create the pull/merge request against <base-branch> with the forge's
tooling — its CLI if one is available, or the creation URL most forges
print when you push — following the repo's PR template and conventions if
present, and report the URL to your human partner.

Keep the worktree — your human partner iterates on PR feedback there.

**Do NOT archive the spec/plan yet, and leave the spec `Status: implemented`** — the PR is open, not merged. `released` and archiving (`active/` → `archive/`, ADR) belong once the change actually lands in the base branch. Remind your human partner to set the spec to `released` and move the spec and plan to `archive/` after the PR merges (or re-run this skill's archive step at that point).

### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

### If your human partner asks to discard the work

This path exists only as a response to an explicit request to throw the
work away. Confirm first:

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for that exact confirmation. When it arrives:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then clean up the worktree (Step 6) and force-delete the branch:

```bash
git branch -D <feature-branch>
```

## Step 6: Cleanup Workspace

**Runs for Option 1 and confirmed discards.** Options 2 and 3 always
preserve the worktree. Both callers have already changed directory to the
main repo root — worktree removal must run from outside the worktree —
and use the `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` values captured in
Step 2, from before that directory change.

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

**If `WORKTREE_PATH` is under `.worktrees/` or `worktrees/`:** Superpowers
created this worktree — we own cleanup:

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**Otherwise:** The host environment owns this workspace — leave it in
place. If your platform provides a workspace-exit tool, use it.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch | Spec status | Archive spec/plan |
|--------|-------|------|---------------|----------------|-------------|-------------------|
| 1. Merge locally | yes | - | - | yes | implemented → released | yes (active→archive, ADR) |
| 2. Create PR | - | yes | yes | - | implemented (→ released after merge) | after PR merges |
| 3. Keep as-is | - | - | yes | - | implemented | - |
| Discard (explicit request only) | - | - | - | yes (force) | - | - |

Step 1 sets `implemented` for every option once tests pass (a `draft` spec is left un-promoted); only a local merge promotes it to `released`. Discard deletes the feature branch — and with it Step 1's `implemented` commit — so the spec reverts to its prior status on the base branch.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests passed earlier this session" | Run the suite on the tree you are about to integrate. A green run only proves the tree it ran on. |
| "They obviously want it merged" | Integration is your human partner's decision. Present the menu and wait. |
| "They seem done with this feature — I'll offer to discard it" | The menu is complete as written. Discard happens only when your human partner asks for it in so many words. |
| "'Yeah, get rid of it' counts as confirmation" | Only the typed word `discard` authorizes deletion. |
| "The PR is up, so the worktree is clutter now" | PR feedback gets fixed in that worktree. It stays until the work lands. |
| "This other worktree looks stale — I'll clean it too" | Clean up only worktrees under `.worktrees/` or `worktrees/`. Everything else belongs to the host. |
| "The merged-result failure is probably flaky" | A failing merged result stops everything. Branch and worktree stay put while you investigate. |
| "The base branch is obviously main" | Confirm the fork point or ask. Merging into the wrong base is expensive to undo. |
| "The push was rejected — force-push will fix it" | A rejected push means the remote moved. Investigate; force-push only on your human partner's explicit request. |
