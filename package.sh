#!/usr/bin/env bash
# Builds Release with the project's own publish/zip targets and packages dist/Deathmatch.zip:
#   addons/counterstrikesharp/plugins/Deathmatch/...       (dll, deps, lang/, spawns/)
#   addons/counterstrikesharp/shared/DeathmatchAPI/...     (shared API)
# Also writes dist/release-notes.md from the matching CHANGELOG.md section.
#
# Usage: ./package.sh [X.Y.Z]   (version defaults to ModuleVersion; when given it must match)
set -euo pipefail
cd "$(dirname "$0")"

PLUGIN=Deathmatch

SOURCE_VERSION="$(grep -rhoP 'ModuleVersion => "\K[^"]+' source/Deathmatch --include=*.cs | head -1)"
VERSION="${1:-$SOURCE_VERSION}"
if [[ -z "$SOURCE_VERSION" || "$VERSION" != "$SOURCE_VERSION" ]]; then
    echo "ERROR: version $VERSION does not match ModuleVersion ($SOURCE_VERSION)" >&2
    exit 1
fi

NOTES="$(awk -v v="$VERSION" '$0 ~ "^## " { if (found) exit; found = ($2 == v); next } found' CHANGELOG.md)"
if [[ -z "${NOTES//[[:space:]]/}" ]]; then
    echo "ERROR: CHANGELOG.md has no \"## $VERSION\" section" >&2
    exit 1
fi

rm -rf dist source/Deathmatch/bin source/DeathmatchAPI/bin
dotnet publish source/Deathmatch/Deathmatch.csproj -c Release

STAGE=dist/stage
mkdir -p "$STAGE"
unzip -q source/Deathmatch/bin/Deathmatch.zip -d "$STAGE"

# Linux only, no debug symbols or backups.
find "$STAGE" \( -name '*.pdb' -o -name '*.bak' \) -delete
find "$STAGE" -type d -path '*/runtimes/*' -prune ! -name linux-x64 ! -name unix -exec rm -rf {} +

test -f "$STAGE/addons/counterstrikesharp/plugins/$PLUGIN/$PLUGIN.dll"
test -f "$STAGE/addons/counterstrikesharp/shared/DeathmatchAPI/DeathmatchAPI.dll"
if [[ -d "$STAGE/addons/counterstrikesharp/configs" ]]; then
    echo "ERROR: configs/ must never be shipped" >&2
    exit 1
fi

(cd "$STAGE" && zip -qr "../$PLUGIN.zip" addons)
rm -rf "$STAGE"
printf '%s\n' "$NOTES" > dist/release-notes.md

unzip -l "dist/$PLUGIN.zip"
echo "==> dist/$PLUGIN.zip ($VERSION)"
