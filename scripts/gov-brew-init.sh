#!/bin/bash
set -e

TAP_NAME="bromag/ch-gov-brew"
TAP_PATH="/opt/homebrew/Library/Taps/bromag/homebrew-ch-gov-brew"

echo "Refreshing tap $TAP_NAME..."
brew untap --force "$TAP_NAME"
brew tap "$TAP_NAME"

echo "Registering formulae..."
if [ -d "$TAP_PATH/Formula" ]; then
  for f in "$TAP_PATH/Formula"/*.rb; do
    [ -e "$f" ] || continue
    name=$(basename "$f" .rb)
    brew info --json=v2 "$TAP_NAME/$name" >/dev/null 2>&1 || true
  done
fi

echo "Registering casks..."
if [ -d "$TAP_PATH/Casks" ]; then
  for c in "$TAP_PATH/Casks"/*.rb; do
    [ -e "$c" ] || continue
    name=$(basename "$c" .rb)
    brew info --json=v2 --cask "$TAP_NAME/$name" >/dev/null 2>&1 || true
  done
fi

echo "gov-brew tap setup complete."