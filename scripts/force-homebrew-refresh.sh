#!/bin/bash
TAP_NAME="bromag/ch-gov-brew"

for rb in /opt/homebrew/Library/Taps/bromag/homebrew-ch-gov-brew/Casks/*.rb; do
  FILE=$(basename "$rb" .rb)
  brew info --json=v2 --cask "$TAP_NAME/$FILE" >/dev/null 2>&1
done

for rb in /opt/homebrew/Library/Taps/bromag/homebrew-ch-gov-brew/Formula/*.rb; do
  FILE=$(basename "$rb" .rb)
  brew info --json=v2 "$TAP_NAME/$FILE" >/dev/null 2>&1
done