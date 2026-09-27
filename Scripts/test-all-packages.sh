#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGES="
BaseCore
DomainCore
NetworkCore
DesignSystem
StorageCore
TCAAdapters
AppFeature
"

export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-/private/tmp/codex-clang-cache}"

for package in $PACKAGES; do
    echo "==> Testing $package"
    (
        cd "$ROOT_DIR/Packages/$package"
        swift test --disable-sandbox
    )
done
