#!/usr/bin/env bash
# Regression check: spec-update accepts draft specs as the no-ceremony editor.
# Both intents are draft-mapped and body-only (no plan, no code from a draft);
# Open Questions are read-write under the spec-brainstorming rules; promotion
# draft → in_progress happens only at the terminal, only on the user's yes,
# only when every Open Question is resolved, and never invokes writing-plans;
# full build/review rounds stay with spec-brainstorming; the change is
# mirrored in README under "Changes from Original Superpowers".

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SPEC_UPDATE_MD="$REPO_ROOT/skills/spec-update/SKILL.md"
SPEC_SKILL_MD="$REPO_ROOT/skills/spec-brainstorming/SKILL.md"
README="$REPO_ROOT/README.md"

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

assert_not_contains() {
    local file="$1" pattern="$2" label="$3"
    if grep -Fq "$pattern" "$file"; then
        echo "  [FAIL] $label"
        echo "    Did not expect to find: $pattern"
        echo "    In file: $file"
        failures=$((failures + 1))
    else
        echo "  [PASS] $label"
    fi
}

echo "=== Spec-Update Draft Support Test ==="
echo ""

# Drafts are accepted targets (description + OPT-IN), split from
# spec-brainstorming by ceremony weight, not status.
assert_contains "$SPEC_UPDATE_MD" "Update an existing spec at Status: draft, in_progress, or implemented" "description accepts drafts"
assert_contains "$SPEC_UPDATE_MD" "The boundary is ceremony weight, not status" "routing splits by ceremony weight, not status"
assert_not_contains "$SPEC_UPDATE_MD" "Do NOT edit a \`draft\` (route to \`spec-brainstorming\`)" "no blanket draft refusal left in the hard gate"

# Body-only hard gate: a draft is never planned from or built.
assert_contains "$SPEC_UPDATE_MD" "**Evolve mode (draft):** body-only" "draft evolve is body-only"
assert_contains "$SPEC_UPDATE_MD" "nothing is ever built from it in this skill" "nothing is built from a draft"

# Draft Mode maps both intents.
assert_contains "$SPEC_UPDATE_MD" "## Draft Mode" "Draft Mode section exists"
assert_contains "$SPEC_UPDATE_MD" "Reconcile-on-draft" "reconcile is draft-mapped"
assert_contains "$SPEC_UPDATE_MD" "Evolve-on-draft" "evolve is draft-mapped"
assert_contains "$SPEC_UPDATE_MD" "codebase it describes" "draft reconcile compares against the codebase, not a diff/plan"

# Open Questions are read-write under the shared rules.
assert_contains "$SPEC_UPDATE_MD" "read-write under the same rules as both \`spec-brainstorming\` rounds" "Open Questions are read-write"

# Promotion: terminal offer only, gated on every Open Question resolved,
# never followed by a writing-plans invocation.
assert_contains "$SPEC_UPDATE_MD" "ONLY on the user's yes to the promotion offer and ONLY when every Open Question is \`- [x]\`" "promotion gated on user yes + resolved Open Questions"
assert_contains "$SPEC_UPDATE_MD" "draft ──(spec-update: terminal promotion offer accepted)──▶ in_progress" "lifecycle diagram shows the promotion edge"
assert_contains "$SPEC_UPDATE_MD" "promote this spec to \`in_progress\`?" "terminal offers promotion"
assert_contains "$SPEC_UPDATE_MD" "never invokes \`writing-plans\`" "never invokes writing-plans"
assert_contains "$SPEC_UPDATE_MD" "list the remaining open questions as blockers" "unsatisfied gate lists blockers"

# spec-brainstorming cross-references the no-ceremony draft path.
assert_contains "$SPEC_SKILL_MD" "A targeted edit to an existing draft" "spec-brainstorming routes targeted draft edits to spec-update"

# The change is mirrored in README.
assert_contains "$README" "no-ceremony editor for targeted draft edits" "README documents the draft path"
assert_contains "$README" "draft/in_progress/implemented spec" "README skills list includes drafts"

echo ""

if [ "$failures" -gt 0 ]; then
    echo "STATUS: FAILED ($failures failures)"
    exit 1
fi

echo "STATUS: PASSED"
