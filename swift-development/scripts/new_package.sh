#!/bin/bash
# Creates a new Swift package with common configuration
# Usage: new_package.sh <name> [--type library|executable|empty] [--ios] [--macos] [--swift-version 5.10|6.0]

set -e

# Check prerequisites
if ! command -v swift &> /dev/null; then
    echo "Error: swift is not available. Install Xcode Command Line Tools: xcode-select --install" >&2
    exit 1
fi

NAME="${1:?Usage: new_package.sh <name> [--type library|executable|empty] [--ios] [--macos] [--swift-version 5.10|6.0]}"
TYPE="library"
PLATFORMS=""
SWIFT_VERSION="5.10"

# Get script directory to find assets
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../assets"
if [[ -d "$ASSETS_DIR" ]]; then
    ASSETS_DIR="$(cd "$ASSETS_DIR" && pwd)"
else
    ASSETS_DIR=""  # Assets not available, will use inline configs
fi

shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --type) TYPE="$2"; shift 2 ;;
        --ios) PLATFORMS="${PLATFORMS}iOS "; shift ;;
        --macos) PLATFORMS="${PLATFORMS}macOS "; shift ;;
        --swift-version) SWIFT_VERSION="$2"; shift 2 ;;
        *) echo "Error: Unknown option: $1" >&2; echo "Usage: new_package.sh <name> [--type library|executable|empty] [--ios] [--macos] [--swift-version 5.10|6.0]" >&2; exit 1 ;;
    esac
done

# Validate package name
if [[ ! "$NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
    echo "Error: Invalid package name '$NAME'. Must start with a letter and contain only alphanumeric characters, hyphens, and underscores." >&2
    exit 1
fi

# Check if directory already exists
if [[ -e "$NAME" ]]; then
    echo "Error: Directory '$NAME' already exists." >&2
    exit 1
fi

echo "Creating Swift package: $NAME (type: $TYPE, Swift $SWIFT_VERSION)"

# Create package
if ! swift package init --type "$TYPE" --name "$NAME"; then
    echo "Error: Failed to create Swift package" >&2
    exit 1
fi

cd "$NAME"

# If platforms specified, update Package.swift
if [[ -n "$PLATFORMS" ]]; then
    echo "Adding platform support: $PLATFORMS"

    # Build platforms array
    PLATFORM_ARRAY=""
    [[ "$PLATFORMS" == *"iOS"* ]] && PLATFORM_ARRAY="${PLATFORM_ARRAY}.iOS(.v15), "
    [[ "$PLATFORMS" == *"macOS"* ]] && PLATFORM_ARRAY="${PLATFORM_ARRAY}.macOS(.v13), "
    PLATFORM_ARRAY="${PLATFORM_ARRAY%, }"

    # Insert platforms into Package.swift after 'name:'
    sed -i '' "s/name: \"$NAME\"/name: \"$NAME\",\n    platforms: [$PLATFORM_ARRAY]/" Package.swift
fi

# Create standard directories
mkdir -p Sources/$NAME/{Models,Services,Utilities}
mkdir -p Tests/${NAME}Tests

# Add .gitignore
cat > .gitignore << 'EOF'
.DS_Store
/.build
/Packages
xcuserdata/
DerivedData/
.swiftpm/
*.xcodeproj
Package.resolved
EOF

# Add SwiftFormat config (use asset if available, otherwise create inline)
if [[ -n "$ASSETS_DIR" && -f "$ASSETS_DIR/.swiftformat" ]]; then
    echo "Using SwiftFormat config from assets..."
    cp "$ASSETS_DIR/.swiftformat" .swiftformat
    # Update swiftversion if different
    if [[ "$SWIFT_VERSION" != "5.10" ]]; then
        sed -i '' "s/--swiftversion 5.10/--swiftversion $SWIFT_VERSION/" .swiftformat 2>/dev/null || \
        sed -i '' "s/--swiftversion .*/--swiftversion $SWIFT_VERSION/" .swiftformat 2>/dev/null || true
    fi
else
    echo "Creating SwiftFormat config..."
    cat > .swiftformat << EOF
--indent 4
--indentcase false
--trimwhitespace always
--voidtype void
--wraparguments before-first
--wrapcollections before-first
--maxwidth 120
--swiftversion $SWIFT_VERSION
--exclude Pods,Generated,*.generated.swift
--disable redundantSelf
--enable isEmpty
EOF
fi

# Add SwiftLint config (use asset if available, otherwise create inline)
if [[ -n "$ASSETS_DIR" && -f "$ASSETS_DIR/.swiftlint.yml" ]]; then
    echo "Using SwiftLint config from assets..."
    cp "$ASSETS_DIR/.swiftlint.yml" .swiftlint.yml
else
    echo "Creating SwiftLint config..."
    cat > .swiftlint.yml << 'EOF'
disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - closure_spacing

excluded:
  - .build

line_length:
  warning: 120
  error: 200

identifier_name:
  min_length: 2
  excluded:
    - id
    - x
    - y
EOF
fi

echo ""
echo "Package '$NAME' created successfully!"
echo ""
echo "Next steps:"
echo "  cd $NAME"
echo "  swift build"
echo "  swift test"
