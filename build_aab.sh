#!/bin/bash
# build_aab.sh
# Incrementa automáticamente el build number y genera el AAB de release.
# Uso: ./build_aab.sh
#      ./build_aab.sh --major   (sube 2.0.0)
#      ./build_aab.sh --minor   (sube 1.4.0)
#      ./build_aab.sh --patch   (sube 1.3.1)  <- por defecto solo sube build

set -e

PUBSPEC="pubspec.yaml"

# ── Leer versión actual ──────────────────────────────────────────────────────
CURRENT=$(grep '^version:' "$PUBSPEC" | sed 's/version: //')
VERSION_NAME=$(echo "$CURRENT" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT" | cut -d'+' -f2)

MAJOR=$(echo "$VERSION_NAME" | cut -d'.' -f1)
MINOR=$(echo "$VERSION_NAME" | cut -d'.' -f2)
PATCH=$(echo "$VERSION_NAME" | cut -d'.' -f3)

# ── Aplicar bump de versión según flag ──────────────────────────────────────
case "$1" in
  --major)
    MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0
    ;;
  --minor)
    MINOR=$((MINOR + 1)); PATCH=0
    ;;
  --patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_BUILD=$((BUILD_NUMBER + 1))
NEW_VERSION_NAME="${MAJOR}.${MINOR}.${PATCH}"
NEW_VERSION="${NEW_VERSION_NAME}+${NEW_BUILD}"

# ── Actualizar pubspec.yaml ──────────────────────────────────────────────────
echo "📦  $CURRENT  →  $NEW_VERSION"
sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"

# ── Build AAB ───────────────────────────────────────────────────────────────
flutter build appbundle --release

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

echo ""
echo "✅  AAB generado: $NEW_VERSION"
echo "📍  $AAB_PATH"
