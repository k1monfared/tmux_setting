#!/usr/bin/env bash
# Claude Code hook entry: tab-hook.sh <UserPromptSubmit|Notification|Stop|SessionEnd>
# Reads the hook JSON on stdin only for Notification (to tell permission from idle).
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TM="$HERE/../bin/tab-mark"
case "$1" in
    UserPromptSubmit) "$TM" set cc busy ;;
    Stop)             "$TM" set cc done ;;
    SessionEnd)       "$TM" clear cc ;;
    Notification)
        if grep -q 'permission' ; then "$TM" set cc permission; fi ;;
esac
exit 0
