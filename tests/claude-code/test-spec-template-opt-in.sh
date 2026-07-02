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
