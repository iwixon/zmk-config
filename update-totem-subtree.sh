#!/usr/bin/env bash
#
# update-totem-subtree.sh
#
# Purpose: Ensure we have `config/boards/shields/totem` in `main`,
# pulling updates from remote `GEIST/zmk-config-totem/master`.
# If it doesn't exist yet, we do a subtree add; otherwise, we pull.

set -euo pipefail

### 1. Make sure we're at the repo's root directory
cd "$(git rev-parse --show-toplevel)"

### 2. Ensure the `main` branch exists
if ! git rev-parse --verify main >/dev/null 2>&1; then
  echo "[INFO] Creating local 'main' branch from current HEAD..."
  git checkout -b main
else
  echo "[INFO] Checking out local 'main' branch..."
  git checkout main
fi

### 3. Ensure we have a local branch named `geist-master` tracking `GEIST/zmk-config-totem/master`
if ! git rev-parse --verify geist-master >/dev/null 2>&1; then
  echo "[INFO] Creating local branch 'geist-master' to track 'GEIST/zmk-config-totem/master'..."
  git fetch GEIST/zmk-config-totem master
  git checkout -b geist-master remotes/GEIST/zmk-config-totem/master
else
  echo "[INFO] Checking out 'geist-master' and pulling latest..."
  git checkout geist-master
  git pull
fi

### 4. Split out `config/boards/shields/totem` into a new local branch `totem-split`
echo "[INFO] Splitting out config/boards/shields/totem from 'geist-master'..."
git subtree split --prefix=config/boards/shields/totem -b totem-split

### 5. Switch back to `main`
echo "[INFO] Checking out 'main' again..."
git checkout main

### 6. Decide whether to ADD or PULL the subtree
# We'll detect if `config/boards/shields/totem` already exists in HEAD.
if [ -z "$(git ls-tree -d HEAD config/boards/shields/totem 2>/dev/null)" ]; then
  # Doesn't exist → subtree add
  echo "[INFO] Subtree path 'config/boards/shields/totem' not found in 'main'. Doing initial subtree add..."
  git subtree add --prefix=config/boards/shields/totem . totem-split --squash
else
  # Already exists → subtree pull
  echo "[INFO] Subtree path 'config/boards/shields/totem' found. Pulling latest changes..."
  git subtree pull --prefix=config/boards/shields/totem . totem-split --squash
fi

echo "[SUCCESS] Done! 'config/boards/shields/totem' in 'main' is updated."
