#!/bin/bash
# Creates a new Swift package with common configuration
# Usage: new_package.sh <name> [--type library|executable|empty] [--ios] [--macos]

set -e

NAME="${1:?Usage: new_package.sh <name> [--type library|executable|empty] [--ios] [--macos]}"
TYPE="library"
PLATFORMS=""

shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --type) TYPE="$2"; shift 2 ;;
        --ios) PLATFORMS="${PLATFORMS}iOS "; shift ;;
        --macos) PLATFORMS="${PLATFORMS}macOS "; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "Creating Swift package: $NAME (type: $TYPE)"

# Create package
swift package init --type "$TYPE" --name "$NAME"
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

# Add SwiftFormat config
cat > .swiftformat << 'EOF'
--indent 4
--indentcase false
--trimwhitespace always
--voidtype void
--wraparguments before-first
--wrapcollections before-first
--maxwidth 120
--swiftversion 5.10
EOF

# Add SwiftLint config
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

echo ""
echo "Package '$NAME' created successfully!"
echo ""
echo "Next steps:"
echo "  cd $NAME"
echo "  swift build"
echo "  swift test"
