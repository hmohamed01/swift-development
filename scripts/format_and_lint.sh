#!/bin/bash
# Format and lint Swift code
# Usage: format_and_lint.sh [path] [--fix] [--check]
#   --fix     Auto-fix issues (default)
#   --check   Check only, don't modify files

set -e

PATH_TO_CHECK="${1:-.}"
MODE="fix"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --fix) MODE="fix" ;;
        --check) MODE="check" ;;
    esac
done

# Shift path argument if it's not a flag
[[ "$1" != --* ]] && shift

HAS_ERRORS=0

# SwiftFormat
if command -v swiftformat &> /dev/null; then
    echo "Running SwiftFormat..."
    if [[ "$MODE" == "check" ]]; then
        swiftformat --lint "$PATH_TO_CHECK" || HAS_ERRORS=1
    else
        swiftformat "$PATH_TO_CHECK"
    fi
else
    echo "SwiftFormat not found. Install with: brew install swiftformat"
fi

echo ""

# SwiftLint
if command -v swiftlint &> /dev/null; then
    echo "Running SwiftLint..."
    if [[ "$MODE" == "check" ]]; then
        swiftlint lint --path "$PATH_TO_CHECK" --strict || HAS_ERRORS=1
    else
        swiftlint --fix --path "$PATH_TO_CHECK"
        # Run lint after fix to show remaining issues
        swiftlint lint --path "$PATH_TO_CHECK" || HAS_ERRORS=1
    fi
else
    echo "SwiftLint not found. Install with: brew install swiftlint"
fi

echo ""

# Apple's swift-format (if available)
if command -v swift-format &> /dev/null; then
    echo "Running swift-format..."
    if [[ "$MODE" == "check" ]]; then
        swift-format lint -r "$PATH_TO_CHECK" || HAS_ERRORS=1
    else
        swift-format -i -r "$PATH_TO_CHECK"
    fi
fi

if [[ $HAS_ERRORS -eq 1 ]]; then
    echo ""
    echo "Some issues were found. Run with --fix to auto-correct."
    exit 1
else
    echo "All checks passed!"
fi
