#!/bin/bash

BREW_ORIG="/opt/homebrew/bin/brew-original"
ALLOWED_TAP="bromag/ch-gov-brew"

CMD="$1"
shift

# Parse args
TARGET=""
IS_CASK=0

for arg in "$@"; do
  if [[ "$arg" == "--cask" ]]; then
    IS_CASK=1
  elif [[ ! "$arg" =~ ^- ]] && [[ -z "$TARGET" ]]; then
    TARGET="$arg"
  fi
done

if [[ "$CMD" == "install" && -n "$TARGET" ]]; then
  if [[ "$IS_CASK" == 1 ]]; then
    TAP=$("$BREW_ORIG" info --json=v2 --cask "$TARGET" 2>/dev/null | jq -r '.casks[0].tap')
  else
    TAP=$("$BREW_ORIG" info --json=v2 "$TARGET" 2>/dev/null | jq -r '.formulae[0].tap')
  fi

  echo "(/) Debug: Requested item = $TARGET"
  echo "(/) Debug: Detected tap = $TAP"

  if [[ "$TAP" != "$ALLOWED_TAP" ]]; then
    echo "(X) Access Denied: Only items from '$ALLOWED_TAP' are allowed."
    exit 1
  fi
fi

exec "$BREW_ORIG" "$CMD" "$@"