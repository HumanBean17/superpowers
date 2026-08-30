#!/usr/bin/env bash
# Regression check: brainstorming skill supports custom spec templates as pure
# opt-in. No spec-template.md ships by default; the fit check resolves every
# mismatch as a deviation or a template-flag proposal; spec-brainstorming
# carries the same protocol; spec-update inherits it by reference; the change
# is mirrored in README under "Changes from Original Superpowers".

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SKILL_MD="$REPO_ROOT/skills/brainstorming/SKILL.md"
SPEC_SKILL_MD="$REPO_ROOT/skills/spec-brainstorming/SKILL.md"
SPEC_UPDATE_MD="$REPO_ROOT/skills/spec-update/SKILL.md"
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
assert_file_absent "$REPO_ROOT/skills/brainstorming/spec-template.md" "no spec-template.md ships by default"

# The fit check is part of the brainstorming flow.
assert_contains "$SKILL_MD" "spec-template.md" "SKILL.md references the user template file"
assert_contains "$SKILL_MD" "Template fit check" "SKILL.md has the Template fit check step"

# The fit check classifies mismatches and can flag the template itself.
assert_contains "$SKILL_MD" "Incidental" "brainstorming classifies incidental mismatches"
assert_contains "$SKILL_MD" "Structural" "brainstorming classifies structural mismatches"
assert_contains "$SKILL_MD" "template flag" "brainstorming raises the template flag"
assert_contains "$SKILL_MD" "template-improvement proposal" "template written only via approved proposal"

# spec-brainstorming carries the same protocol.
assert_contains "$SPEC_SKILL_MD" "Structural" "spec-brainstorming classifies structural mismatches"
assert_contains "$SPEC_SKILL_MD" "template flag" "spec-brainstorming raises the template flag"
assert_contains "$SPEC_SKILL_MD" "template-improvement proposal" "spec-brainstorming shares the ownership rule"

# spec-update inherits the fit-check protocol by reference.
assert_contains "$SPEC_UPDATE_MD" "Same fit-check protocol as" "spec-update inherits the fit-check protocol"

# The change is mirrored in README.
assert_contains "$README" "Fit Check Can Flag the Template Itself" "README documents the change"

echo ""

if [ "$failures" -gt 0 ]; then
    echo "STATUS: FAILED ($failures failures)"
    exit 1
fi

echo "STATUS: PASSED"
