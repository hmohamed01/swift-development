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

CMD="${1:-list}"
shift || true

case $CMD in
    list)
        xcrun simctl list devices available
        ;;

    boot)
        NAME="${1:?Usage: simulator.sh boot <name>}"
        echo "Booting: $NAME"
        xcrun simctl boot "$NAME" 2>/dev/null || true
        open -a Simulator
        ;;

    shutdown)
        echo "Shutting down all simulators..."
        xcrun simctl shutdown all
        ;;

    reset)
        echo "Resetting all simulators..."
        xcrun simctl shutdown all
        xcrun simctl erase all
        echo "Done!"
        ;;

    install)
        APP="${1:?Usage: simulator.sh install <path/to/app>}"
        echo "Installing: $APP"
        xcrun simctl install booted "$APP"
        ;;

    launch)
        BUNDLE="${1:?Usage: simulator.sh launch <bundle.id>}"
        echo "Launching: $BUNDLE"
        xcrun simctl launch booted "$BUNDLE"
        ;;

    screenshot)
        FILE="${1:-screenshot-$(date +%Y%m%d-%H%M%S).png}"
        xcrun simctl io booted screenshot "$FILE"
        echo "Screenshot saved: $FILE"
        ;;

    dark)
        xcrun simctl ui booted appearance dark
        echo "Dark mode enabled"
        ;;

    light)
        xcrun simctl ui booted appearance light
        echo "Light mode enabled"
        ;;

    *)
        echo "Unknown command: $CMD"
        echo "Usage: simulator.sh <list|boot|shutdown|reset|install|launch|screenshot|dark|light>"
        exit 1
        ;;
esac
