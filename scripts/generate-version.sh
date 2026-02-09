#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
VERSION_FILE="$ROOT/version.env"
VERSION_SWIFT="$ROOT/Sources/facetimectl/Version.swift"
INFO_PLIST="$ROOT/Sources/facetimectl/Resources/Info.plist"

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Error: $VERSION_FILE not found" >&2
  exit 1
fi

# shellcheck source=version.env
source "$VERSION_FILE"

if [[ -z "${VERSION:-}" ]]; then
  echo "Error: VERSION not set in $VERSION_FILE" >&2
  exit 1
fi

# Update Version.swift
cat > "$VERSION_SWIFT" <<EOF
enum RemindctlVersion {
  static let current = "$VERSION"
}
EOF

# Update Info.plist version strings
if [[ -f "$INFO_PLIST" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$INFO_PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $VERSION" "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$INFO_PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $VERSION" "$INFO_PLIST"
fi

echo "Version updated to $VERSION"
