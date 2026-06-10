#!/bin/bash

echo "=== Script de création IPA pour Amethyst Music ==="

BASE_DIR="/Users/enzo/Library/Developer/Xcode/DerivedData"

echo "Recherche des builds AmethystMusic..."
POSSIBLE_BUILDS=($(find "$BASE_DIR" -maxdepth 1 -type d -name "*AmethystMusic*" 2>/dev/null | sort))

if [ ${#POSSIBLE_BUILDS[@]} -eq 0 ]; then
    echo "❌ Aucun dossier AmethystMusic trouvé !"
    echo "Fais d'abord un Build dans Xcode."
    exit 1
fi

if [ ${#POSSIBLE_BUILDS[@]} -gt 1 ]; then
    echo "Plusieurs builds trouvés :"
    for i in "${!POSSIBLE_BUILDS[@]}"; do
        echo "$((i+1))) ${POSSIBLE_BUILDS[i]}"
    done
    read -p "Choisis le numéro du build : " CHOICE
    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#POSSIBLE_BUILDS[@]}" ]; then
        echo "Choix invalide !"
        exit 1
    fi
    SELECTED_BUILD="${POSSIBLE_BUILDS[$((CHOICE-1))]}"
else
    SELECTED_BUILD="${POSSIBLE_BUILDS[0]}"
fi

PRODUCTS_DIR="$SELECTED_BUILD/Build/Products/Debug-iphoneos"

if [ ! -d "$PRODUCTS_DIR" ]; then
    echo "❌ Dossier Products non trouvé !"
    exit 1
fi

APP_FILE=$(find "$PRODUCTS_DIR" -maxdepth 1 -name "*.app" | head -n 1)

if [ -z "$APP_FILE" ]; then
    echo "❌ Aucun .app trouvé !"
    exit 1
fi

echo "✅ .app trouvé : $APP_FILE"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PAYLOAD_DIR="$SCRIPT_DIR/Payload"
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"

NEW_APP_NAME="Amethyst Music.app"
cp -r "$APP_FILE" "$PAYLOAD_DIR/$NEW_APP_NAME"

echo "✅ .app renommé et copié"

IPA_NAME="Amethyst Music.ipa"
cd "$SCRIPT_DIR"
zip -r -q "$IPA_NAME" Payload

rm -rf "$PAYLOAD_DIR"

echo "🎉 IPA créé avec succès !"
echo "📍 $SCRIPT_DIR/$IPA_NAME"
ls -lh "$IPA_NAME"
