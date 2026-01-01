#!/bin/bash
# Run Swift tests with common options
# Usage: run_tests.sh [options]
#   --coverage    Enable code coverage
#   --parallel    Run tests in parallel
#   --filter      Run specific test (e.g., MyTests.testFoo)
#   --verbose     Verbose output
#   --xcode       Use xcodebuild instead of swift test

set -e

# Check prerequisites
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed." >&2
        echo "Install with: $2" >&2
        return 1
    fi
}

COVERAGE=""
PARALLEL=""
FILTER=""
VERBOSE=""
USE_XCODE=false
WORKSPACE=""
SCHEME=""
DESTINATION="platform=iOS Simulator,name=iPhone 15"

while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage) COVERAGE="--enable-code-coverage"; shift ;;
        --parallel) PARALLEL="--parallel"; shift ;;
        --filter) FILTER="--filter $2"; shift 2 ;;
        --verbose) VERBOSE="-v"; shift ;;
        --xcode) USE_XCODE=true; shift ;;
        --workspace) WORKSPACE="$2"; shift 2 ;;
        --scheme) SCHEME="$2"; shift 2 ;;
        --destination) DESTINATION="$2"; shift 2 ;;
        *) echo "Error: Unknown option: $1" >&2; echo "Usage: run_tests.sh [--coverage] [--parallel] [--filter <test>] [--verbose] [--xcode] [--workspace <path>] [--scheme <name>] [--destination <dest>]" >&2; exit 1 ;;
    esac
done

if $USE_XCODE; then
    # Check xcodebuild is available
    if ! check_command xcodebuild "xcode-select --install"; then
        exit 1
    fi

    # xcodebuild mode
    if [[ -z "$WORKSPACE" ]]; then
        # Try to find workspace
        WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" 2>/dev/null | head -1)
        if [[ -z "$WORKSPACE" ]]; then
            PROJECT=$(find . -maxdepth 1 -name "*.xcodeproj" 2>/dev/null | head -1)
            if [[ -n "$PROJECT" ]]; then
                echo "Using project: $PROJECT"
                OUTPUT=$(xcodebuild test \
                    -project "$PROJECT" \
                    -scheme "${SCHEME:-$(basename "$PROJECT" .xcodeproj)}" \
                    -destination "$DESTINATION" \
                    ${COVERAGE:+-enableCodeCoverage YES} 2>&1)
                
                # Use xcpretty if available, otherwise plain output
                if command -v xcpretty &> /dev/null; then
                    echo "$OUTPUT" | xcpretty || echo "$OUTPUT"
                else
                    echo "$OUTPUT"
                fi
                exit 0
            fi
        fi
    fi

    if [[ -n "$WORKSPACE" ]]; then
        echo "Using workspace: $WORKSPACE"
        OUTPUT=$(xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "${SCHEME:-$(basename "$WORKSPACE" .xcworkspace)}" \
            -destination "$DESTINATION" \
            ${COVERAGE:+-enableCodeCoverage YES} 2>&1)
        
        # Use xcpretty if available, otherwise plain output
        if command -v xcpretty &> /dev/null; then
            echo "$OUTPUT" | xcpretty || echo "$OUTPUT"
        else
            echo "$OUTPUT"
        fi
    else
        echo "Error: No workspace or project found." >&2
        echo "Use --workspace <path> or --scheme <name> to specify a project." >&2
        exit 1
    fi
else
    # Check swift is available
    if ! check_command swift "Install Xcode Command Line Tools: xcode-select --install"; then
        exit 1
    fi

    # swift test mode
    echo "Running: swift test $VERBOSE $PARALLEL $COVERAGE $FILTER"
    if ! swift test $VERBOSE $PARALLEL $COVERAGE $FILTER; then
        echo "Error: Tests failed" >&2
        exit 1
    fi

    # Show coverage report if enabled
    if [[ -n "$COVERAGE" ]]; then
        echo ""
        echo "Coverage report:"
        swift test --show-codecov-path 2>/dev/null || echo "Coverage data available in .build/coverage"
    fi
fi

echo ""
echo "Tests completed!"
