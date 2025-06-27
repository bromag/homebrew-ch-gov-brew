#!/bin/bash


###################################################
##
## Script for gov-brew with own tap
##
###################################################

# BREW_ORIG: Path to the original brew binary that you preserved before locking down /opt/homebrew/bin/brew.
# ALLOWED_TAP: The only allowed tap for installing packages. All other sources will be blocked.
BREW_ORIG="/opt/homebrew/bin/brew-original"
ALLOWED_TAP="bromag/ch-gov-brew"

#CMD captures the first argument (e.g., install, info, etc.).
#shift removes the first argument so the rest ($@) only contains the actual item(s) to install.
CMD="$1"
shift


# Initialize flags:
# TARGET: Name of the formula or cask to be installed.
# IS_CASK: Boolean flag (0 or 1) to track whether --cask was passed.
# Parse args
TARGET=""
IS_CASK=0


# This loop processes remaining arguments:
# If --cask is present, sets IS_CASK=1.
# If the argument is not an option (doesn’t start with -) and TARGET hasn’t been set yet, it assumes this is the package name.
for arg in "$@"; do
  if [[ "$arg" == "--cask" ]]; then
    IS_CASK=1
  elif [[ ! "$arg" =~ ^- ]] && [[ -z "$TARGET" ]]; then
    TARGET="$arg"
  fi
done

# Checks if the command is install and a target was identified.
if [[ "$CMD" == "install" && -n "$TARGET" ]]; then

# Determines the source tap of the target:
# Uses brew info --json=v2 to fetch metadata.
# Uses jq to extract the tap field (works for both casks and formulae).
  if [[ "$IS_CASK" == 1 ]]; then
    TAP=$("$BREW_ORIG" info --json=v2 --cask "$TARGET" 2>/dev/null | jq -r '.casks[0].tap')
  else
    TAP=$("$BREW_ORIG" info --json=v2 "$TARGET" 2>/dev/null | jq -r '.formulae[0].tap')
  fi

# Shows debug output so the user sees what is being requested and where it’s coming from.
  echo "(/) Debug: Requested item = $TARGET"
  echo "(/) Debug: Detected tap = $TAP"

# Access control check:
# If the tap doesn’t match the allowed one, deny the install and exit with error.
  if [[ "$TAP" != "$ALLOWED_TAP" ]]; then
    echo "(X) Access Denied: Only items from '$ALLOWED_TAP' are allowed."
    exit 1
  fi
fi

# Finally executes the original brew command with the full command (install, info, etc.) and all remaining arguments.
# exec replaces the current process with the Homebrew process for better efficiency (and cleaner shell output).
exec "$BREW_ORIG" "$CMD" "$@"