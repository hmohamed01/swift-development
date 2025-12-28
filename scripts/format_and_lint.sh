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

# Validate path exists
if [[ ! -e "$PATH_TO_CHECK" ]]; then
    echo "Error: Path '$PATH_TO_CHECK' does not exist." >&2
    exit 1
fi

HAS_ERRORS=0
TOOLS_FOUND=0

# SwiftFormat
if command -v swiftformat &> /dev/null; then
    TOOLS_FOUND=1
    echo "Running SwiftFormat..."
    if [[ "$MODE" == "check" ]]; then
        if ! swiftformat --lint "$PATH_TO_CHECK" 2>&1; then
            HAS_ERRORS=1
        fi
    else
        if ! swiftformat "$PATH_TO_CHECK" 2>&1; then
            echo "Warning: SwiftFormat encountered errors" >&2
            HAS_ERRORS=1
        fi
    fi
else
    echo "Warning: SwiftFormat not found. Install with: brew install swiftformat" >&2
fi

echo ""

# SwiftLint
if command -v swiftlint &> /dev/null; then
    TOOLS_FOUND=1
    echo "Running SwiftLint..."
    if [[ "$MODE" == "check" ]]; then
        if ! swiftlint lint --path "$PATH_TO_CHECK" --strict 2>&1; then
            HAS_ERRORS=1
        fi
    else
        if ! swiftlint --fix --path "$PATH_TO_CHECK" 2>&1; then
            echo "Warning: SwiftLint auto-fix encountered errors" >&2
        fi
        # Run lint after fix to show remaining issues
        if ! swiftlint lint --path "$PATH_TO_CHECK" 2>&1; then
            HAS_ERRORS=1
        fi
    fi
else
    echo "Warning: SwiftLint not found. Install with: brew install swiftlint" >&2
fi

echo ""

# Apple's swift-format (if available)
if command -v swift-format &> /dev/null; then
    TOOLS_FOUND=1
    echo "Running swift-format..."
    if [[ "$MODE" == "check" ]]; then
        if ! swift-format lint -r "$PATH_TO_CHECK" 2>&1; then
            HAS_ERRORS=1
        fi
    else
        if ! swift-format -i -r "$PATH_TO_CHECK" 2>&1; then
            echo "Warning: swift-format encountered errors" >&2
            HAS_ERRORS=1
        fi
    fi
fi

# Check if at least one tool was found
if [[ $TOOLS_FOUND -eq 0 ]]; then
    echo "Error: No formatting/linting tools found." >&2
    echo "Install at least one:" >&2
    echo "  brew install swiftformat" >&2
    echo "  brew install swiftlint" >&2
    exit 1
fi

if [[ $HAS_ERRORS -eq 1 ]]; then
    echo ""
    if [[ "$MODE" == "check" ]]; then
        echo "Some issues were found. Run without --check to auto-correct." >&2
    else
        echo "Some issues remain after auto-fix. Please review manually." >&2
    fi
    exit 1
else
    echo "All checks passed!"
fi
