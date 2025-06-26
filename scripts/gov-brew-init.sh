#!/bin/bash
set -e

TAP_NAME="bromag/ch-gov-brew"
TAP_PATH="/opt/homebrew/Library/Taps/bromag/homebrew-ch-gov-brew"

echo "Ensuring tap '$TAP_NAME' is added..."
if ! brew tap | grep -q "^$TAP_NAME$"; then
  brew tap "$TAP_NAME"
fi

echo "Registering formulae with tap..."
if [ -d "$TAP_PATH/Formula" ]; then
  for rb in "$TAP_PATH"/Formula/*.rb; do
    [ -e "$rb" ] || continue
    file=$(basename "$rb" .rb)
    brew info --json=v2 "$TAP_NAME/$file" >/dev/null 2>&1 || true
  done
fi

echo "Registering casks with tap..."
if [ -d "$TAP_PATH/Casks" ]; then
  for rb in "$TAP_PATH"/Casks/*.rb; do
    [ -e "$rb" ] || continue
    file=$(basename "$rb" .rb)
    brew info --json=v2 --cask "$TAP_NAME/$file" >/dev/null 2>&1 || true
  done
fi

echo "gov-brew tap and metadata are now registered."