#!/bin/bash
set -euo pipefail

usage() {
  echo ""
  echo "Usage:"
  echo "  $0 --config-folder <folder> \\"
  echo "     [--local-xcconfig <file>] \\"
  echo "     [--ogury-mode <local|pod>] \\"
  echo "     [--ogury-framework-name <name>] \\"
  echo "     [--ogury-version-label <label>] \\"
  echo "     [--ogury-pod-name <OgurySdk or OgurySdk-Prod>] \\"
  echo "     [--mediation-framework-name <name>] \\"
  echo "     [--mediation-label <label>] \\"
  echo "     [--version-suffix <optional-suffix>]"
  echo ""
  exit 1
}

# Defaults
OGURY_POD_NAME="OgurySdk-Prod"
MEDIATION_FRAMEWORK_NAME=""
MEDIATION_LABEL=""
VERSION_SUFFIX=""
OGURY_VERSION=""
OGURY_LABEL=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --config-folder) CONFIG_FOLDER="$2"; shift 2 ;;
    --local-xcconfig) LOCAL_XCCONFIG="$2"; shift 2 ;;
    --ogury-mode) OGURY_MODE="$2"; shift 2 ;;
    --ogury-framework-name) OGURY_FRAMEWORK_NAME="$2"; shift 2 ;;
    --ogury-version-label) OGURY_LABEL="$2"; shift 2 ;;
    --ogury-pod-name) OGURY_POD_NAME="$2"; shift 2 ;;
    --mediation-framework-name) MEDIATION_FRAMEWORK_NAME="$2"; shift 2 ;;
    --mediation-label) MEDIATION_LABEL="$2"; shift 2 ;;
    --version-suffix) VERSION_SUFFIX="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
done

# Required: CONFIG_FOLDER
if [[ -z "${CONFIG_FOLDER:-}" ]]; then
  echo "❌ Missing required parameter: --config-folder"
  usage
fi

echo "🔍 Locating the correct Info.plist..."
APP_PLIST="${INFOPLIST_FILE:-}"
if [[ -z "$APP_PLIST" || ! -f "$APP_PLIST" ]]; then
  echo "❌ ERROR: Info.plist not found or INFOPLIST_FILE not set."
  exit 1
fi
echo "📌 Using Info.plist from: $APP_PLIST"

APP_VERSION="${APP_VERSION:-}"
if [ -z "$APP_VERSION" ]; then
  echo "❌ ERROR: APP_VERSION is not set in the environment"
  exit 1
fi

if [[ -n "$VERSION_SUFFIX" ]]; then
  APP_VERSION="${APP_VERSION}-${VERSION_SUFFIX}"
fi

echo "📦 APP_VERSION = $APP_VERSION"

PODFILE_LOCK="${PROJECT_DIR}/../../Podfile.lock"
echo "📦 PODFILE_LOCK = $PODFILE_LOCK"

# Ogury version (optional)
if [[ -n "${OGURY_MODE:-}" ]]; then
  if [[ "$OGURY_MODE" == "local" ]]; then
    if [[ -z "${LOCAL_XCCONFIG:-}" || ! -f "$LOCAL_XCCONFIG" ]]; then
      echo "❌ Local xcconfig not found: $LOCAL_XCCONFIG"
      exit 1
    fi
    OGURY_VERSION=$(grep -E "^MARKETING_VERSION" "$LOCAL_XCCONFIG" | cut -d '=' -f2 | tr -d ' ')
  elif [[ "$OGURY_MODE" == "pod" ]]; then
    if [ ! -f "$PODFILE_LOCK" ]; then
      echo "❌ Podfile.lock not found: $PODFILE_LOCK"
      exit 1
    fi
    echo "📦 Searching for Ogury SDK version in Podfile.lock..."
    OGURY_VERSION_LINE=$(grep -E "^[[:space:]]*-[[:space:]]*(OgurySdk|OgurySdk-Prod)[[:space:]]*\(.*\)" "$PODFILE_LOCK" | head -n1)
    if [[ -z "$OGURY_VERSION_LINE" ]]; then
      echo "❌ OgurySdk or OgurySdk-Prod not found in Podfile.lock"
      exit 1
    fi
    OGURY_VERSION=$(echo "$OGURY_VERSION_LINE" | sed -E 's/.*\(([^)]+)\).*/\1/')
    if [[ -z "$OGURY_VERSION" ]]; then
      echo "❌ Failed to extract Ogury version from line: $OGURY_VERSION_LINE"
      exit 1
    fi
    echo "🎯 OgurySDK version: $OGURY_VERSION"
  else
    echo "❌ Invalid ogury-mode: $OGURY_MODE"
    usage
  fi
fi

# Mediation SDK version (optional)
MEDIATION_VERSION=""
if [[ -n "$MEDIATION_FRAMEWORK_NAME" && -n "$MEDIATION_LABEL" && -f "$PODFILE_LOCK" ]]; then
  MEDIATION_VERSION=$(grep -E "^[[:space:]]*-[[:space:]]*${MEDIATION_FRAMEWORK_NAME}[[:space:]]*\(.*\)" "$PODFILE_LOCK" \
    | grep -v "~>" \
    | sed -E 's/.*\(([0-9]+\.[0-9]+\.[0-9]+).*\).*/\1/' \
    | head -n1)
  if [ -n "$MEDIATION_VERSION" ]; then
    echo "🔌 Mediation version (${MEDIATION_LABEL}): $MEDIATION_VERSION"
  fi
fi

# Determine config paths
if [[ "${OGURY_MODE:-}" == "pod" && "$CONFIG_FOLDER" == AdsTestApp/Config/Ogury/* ]]; then
  CONFIG_DEBUG="${SRCROOT}/${CONFIG_FOLDER}/config-art.debug.xcconfig"
  CONFIG_RELEASE="${SRCROOT}/${CONFIG_FOLDER}/config-art.release.xcconfig"
else
  CONFIG_DEBUG="${SRCROOT}/${CONFIG_FOLDER}/config.debug.xcconfig"
  CONFIG_RELEASE="${SRCROOT}/${CONFIG_FOLDER}/config.release.xcconfig"
fi

echo "🛠️ Using config files:"
echo "  $CONFIG_DEBUG"
echo "  $CONFIG_RELEASE"

# Extract CUSTOM_VERSION
CUSTOM_VERSION=$(sed -nE 's/^[[:space:]]*CUSTOM_VERSION[[:space:]]*=[[:space:]]*(.*)/\1/p' "$CONFIG_DEBUG" 2>/dev/null | tr -d '\r' | head -n1 || true)
if [ -z "$CUSTOM_VERSION" ] && [ -f "$CONFIG_RELEASE" ]; then
  CUSTOM_VERSION=$(sed -nE 's/^[[:space:]]*CUSTOM_VERSION[[:space:]]*=[[:space:]]*(.*)/\1/p' "$CONFIG_RELEASE" 2>/dev/null | tr -d '\r' | head -n1 || true)
fi

# Build final version string
if [[ -n "$CUSTOM_VERSION" ]]; then
  echo "✨ Found CUSTOM_VERSION=$CUSTOM_VERSION"
  VERSION_STRING="${APP_VERSION}-${CUSTOM_VERSION}"
else
  VERSION_STRING="${APP_VERSION}"
  if [[ -n "$OGURY_LABEL" && -n "$OGURY_VERSION" ]]; then
    VERSION_STRING="${VERSION_STRING}+${OGURY_LABEL}.${OGURY_VERSION}"
  fi
  if [[ -n "$MEDIATION_VERSION" ]]; then
    VERSION_STRING="${VERSION_STRING}.${MEDIATION_LABEL}.${MEDIATION_VERSION}"
  fi
fi

echo "📝 Final version string: $VERSION_STRING"

BUILD_NUMBER="build:$(date +%s)"

for FILE in "$CONFIG_DEBUG" "$CONFIG_RELEASE"; do
  if [ ! -f "$FILE" ]; then
    echo "❌ Config file not found: $FILE"
    exit 1
  fi

  echo "🧹 Cleaning old values in $FILE"
  sed -i '' '/^VERSION[[:space:]]*=/d' "$FILE"
  sed -i '' '/^BUILD_NUMBER[[:space:]]*=/d' "$FILE"

  echo "➕ Adding VERSION and BUILD_NUMBER"
  echo "VERSION = $VERSION_STRING" >> "$FILE"
  echo "BUILD_NUMBER = $BUILD_NUMBER" >> "$FILE"

  echo "✅ Updated $FILE"
done