#!/bin/bash
# ============================================================
# Build de release para Google Play Store - El Desembale
# ============================================================
# Uso: ./scripts/build_playstore.sh [nueva_version] [nuevo_version_code]
# Ejemplo: ./scripts/build_playstore.sh 1.1.0 11
# Sin argumentos: usa la versión actual del pubspec.yaml
# ============================================================

set -e

FLUTTER="/Users/andres/development/flutter/bin/flutter"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$PROJECT_DIR/pubspec.yaml"
KEY_PROPERTIES="$PROJECT_DIR/android/key.properties"
AAB_OUTPUT="$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"

cd "$PROJECT_DIR"

# ── Verificar key.properties ──────────────────────────────
if [ ! -f "$KEY_PROPERTIES" ]; then
  echo ""
  echo "❌ ERROR: No se encontró android/key.properties"
  echo ""
  echo "Crea el archivo copiando la plantilla:"
  echo "  cp android/key.properties.template android/key.properties"
  echo ""
  echo "Luego edítalo con los datos del keystore (KeyGD.keystore)."
  echo "Pídele a Felipe el archivo .keystore y las contraseñas."
  echo ""
  exit 1
fi

# ── Bump de versión (opcional) ────────────────────────────
NEW_VERSION="$1"
NEW_VERSION_CODE="$2"

if [ -n "$NEW_VERSION" ] && [ -n "$NEW_VERSION_CODE" ]; then
  echo "📦 Actualizando versión → $NEW_VERSION+$NEW_VERSION_CODE"
  # Actualiza pubspec.yaml
  sed -i '' "s/^version: .*/version: $NEW_VERSION+$NEW_VERSION_CODE/" "$PUBSPEC"
  # Actualiza build.gradle
  sed -i '' "s/versionCode = [0-9]*/versionCode = $NEW_VERSION_CODE/" "$PROJECT_DIR/android/app/build.gradle"
  sed -i '' "s/versionName = \".*\"/versionName = \"$NEW_VERSION\"/" "$PROJECT_DIR/android/app/build.gradle"
  echo "✅ pubspec.yaml y build.gradle actualizados"
fi

# ── Versión actual ────────────────────────────────────────
CURRENT_VERSION=$(grep '^version:' "$PUBSPEC" | awk '{print $2}')
echo ""
echo "🚀 Construyendo versión $CURRENT_VERSION para Play Store..."
echo ""

# ── Clean + Build AAB ─────────────────────────────────────
$FLUTTER clean
$FLUTTER pub get
$FLUTTER build appbundle --release

# ── Resultado ─────────────────────────────────────────────
if [ -f "$AAB_OUTPUT" ]; then
  AAB_SIZE=$(du -sh "$AAB_OUTPUT" | awk '{print $1}')
  echo ""
  echo "✅ Build exitoso"
  echo ""
  echo "📁 Archivo AAB:"
  echo "   $AAB_OUTPUT"
  echo "   Tamaño: $AAB_SIZE"
  echo ""
  echo "📋 Próximos pasos:"
  echo "   1. Abre Google Play Console → El Desembale"
  echo "   2. Producción (o Track de prueba) → Crear nueva versión"
  echo "   3. Sube el archivo .aab"
  echo "   4. Agrega notas de la versión en español"
  echo "   5. Revisa y publica"
  echo ""
  # Abrir carpeta del AAB en Finder
  open "$(dirname "$AAB_OUTPUT")"
else
  echo ""
  echo "❌ No se encontró el AAB. Revisa los errores anteriores."
  exit 1
fi
