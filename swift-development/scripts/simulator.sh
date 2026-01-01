#!/bin/bash
# Quick simulator management
# Usage: simulator.sh <command> [args]
#   list              List all simulators
#   boot <name>       Boot simulator by name
#   shutdown          Shutdown all simulators
#   reset             Reset all simulators
#   install <app>     Install app on booted simulator
#   launch <bundleid> Launch app by bundle ID
#   screenshot [file] Take screenshot
#   dark              Enable dark mode
#   light             Enable light mode

set -e

# Check prerequisites
if ! command -v xcrun &> /dev/null; then
    echo "Error: xcrun is not available. Install Xcode Command Line Tools: xcode-select --install" >&2
    exit 1
fi

if ! xcrun simctl help &> /dev/null; then
    echo "Error: simctl is not available. Install Xcode Command Line Tools: xcode-select --install" >&2
    exit 1
fi

CMD="${1:-list}"
shift || true

case $CMD in
    list)
        if ! xcrun simctl list devices available 2>&1; then
            echo "Error: Failed to list simulators" >&2
            exit 1
        fi
        ;;

    boot)
        NAME="${1:?Usage: simulator.sh boot <name>}"
        echo "Booting: $NAME"
        if ! xcrun simctl boot "$NAME" 2>/dev/null; then
            # Check if already booted or if there's an error
            if xcrun simctl list devices | grep -q "$NAME.*Booted"; then
                echo "Simulator '$NAME' is already booted"
            else
                echo "Error: Failed to boot simulator '$NAME'" >&2
                echo "Available simulators:" >&2
                xcrun simctl list devices available | grep -i "$NAME" || true
                exit 1
            fi
        fi
        if command -v open &> /dev/null; then
            open -a Simulator 2>/dev/null || true
        fi
        ;;

    shutdown)
        echo "Shutting down all simulators..."
        if ! xcrun simctl shutdown all 2>&1; then
            echo "Warning: Some simulators may not have shut down properly" >&2
        fi
        ;;

    reset)
        echo "Resetting all simulators..."
        echo "Warning: This will erase all simulator data!" >&2
        if ! xcrun simctl shutdown all 2>&1; then
            echo "Warning: Some simulators may not have shut down properly" >&2
        fi
        if ! xcrun simctl erase all 2>&1; then
            echo "Error: Failed to reset simulators" >&2
            exit 1
        fi
        echo "Done!"
        ;;

    install)
        APP="${1:?Usage: simulator.sh install <path/to/app>}"
        if [[ ! -e "$APP" ]]; then
            echo "Error: App path '$APP' does not exist" >&2
            exit 1
        fi
        echo "Installing: $APP"
        if ! xcrun simctl install booted "$APP" 2>&1; then
            echo "Error: Failed to install app. Make sure a simulator is booted." >&2
            exit 1
        fi
        ;;

    launch)
        BUNDLE="${1:?Usage: simulator.sh launch <bundle.id>}"
        echo "Launching: $BUNDLE"
        if ! xcrun simctl launch booted "$BUNDLE" 2>&1; then
            echo "Error: Failed to launch app with bundle ID '$BUNDLE'" >&2
            echo "Make sure the app is installed and a simulator is booted." >&2
            exit 1
        fi
        ;;

    screenshot)
        FILE="${1:-screenshot-$(date +%Y%m%d-%H%M%S).png}"
        if ! xcrun simctl io booted screenshot "$FILE" 2>&1; then
            echo "Error: Failed to take screenshot. Make sure a simulator is booted." >&2
            exit 1
        fi
        echo "Screenshot saved: $FILE"
        ;;

    dark)
        if ! xcrun simctl ui booted appearance dark 2>&1; then
            echo "Error: Failed to set dark mode. Make sure a simulator is booted." >&2
            exit 1
        fi
        echo "Dark mode enabled"
        ;;

    light)
        if ! xcrun simctl ui booted appearance light 2>&1; then
            echo "Error: Failed to set light mode. Make sure a simulator is booted." >&2
            exit 1
        fi
        echo "Light mode enabled"
        ;;

    *)
        echo "Error: Unknown command: $CMD" >&2
        echo "Usage: simulator.sh <list|boot|shutdown|reset|install|launch|screenshot|dark|light>" >&2
        exit 1
        ;;
esac
