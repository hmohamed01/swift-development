#!/bin/bash
# Run Swift tests with common options
# Usage: run_tests.sh [options]
#   --coverage    Enable code coverage
#   --parallel    Run tests in parallel
#   --filter      Run specific test (e.g., MyTests.testFoo)
#   --verbose     Verbose output
#   --xcode       Use xcodebuild instead of swift test

set -e

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
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if $USE_XCODE; then
    # xcodebuild mode
    if [[ -z "$WORKSPACE" ]]; then
        # Try to find workspace
        WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" | head -1)
        if [[ -z "$WORKSPACE" ]]; then
            PROJECT=$(find . -maxdepth 1 -name "*.xcodeproj" | head -1)
            if [[ -n "$PROJECT" ]]; then
                echo "Using project: $PROJECT"
                xcodebuild test \
                    -project "$PROJECT" \
                    -scheme "${SCHEME:-$(basename "$PROJECT" .xcodeproj)}" \
                    -destination "$DESTINATION" \
                    ${COVERAGE:+-enableCodeCoverage YES} \
                    | xcpretty || cat
                exit 0
            fi
        fi
    fi

    if [[ -n "$WORKSPACE" ]]; then
        echo "Using workspace: $WORKSPACE"
        xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "${SCHEME:-$(basename "$WORKSPACE" .xcworkspace)}" \
            -destination "$DESTINATION" \
            ${COVERAGE:+-enableCodeCoverage YES} \
            | xcpretty || cat
    else
        echo "No workspace or project found. Use --workspace or --scheme"
        exit 1
    fi
else
    # swift test mode
    echo "Running: swift test $VERBOSE $PARALLEL $COVERAGE $FILTER"
    swift test $VERBOSE $PARALLEL $COVERAGE $FILTER

    # Show coverage report if enabled
    if [[ -n "$COVERAGE" ]]; then
        echo ""
        echo "Coverage report:"
        swift test --show-codecov-path 2>/dev/null || true
    fi
fi

echo ""
echo "Tests completed!"
