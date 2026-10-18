#!/bin/bash
# Captures d'écran pour l'App Store, en français et en anglais : sur iPhone 6,3" (1206 × 2622)
# et sur iPad 13" (2064 × 2752).
#
# Usage : .github/scripts/screenshots.sh <dossier de sortie>
#
# Les écrans capturés sont choisis dans integration_test/screenshots_test.dart.
set -euo pipefail

OUT="$1"

# Horodatage, pour voir quelle étape prend du temps
log() {
    echo "[$(date -u +%H:%M:%S)] $*"
}

# Commande simctl avec un délai maximal : un simulateur bloqué fait échouer le job au lieu de
# l'occuper jusqu'à son délai. macOS n'a pas `timeout` : alarm de perl.
sim() {
    local seconds="$1"
    shift
    perl -e 'alarm shift; exec @ARGV' "$seconds" xcrun simctl "$@"
}

RUNTIME=$(xcrun simctl list runtimes available -j \
    | jq -r '[.runtimes[] | select(.platform == "iOS")] | sort_by(.version | split(".") | map(tonumber)) | last | .identifier')
echo "Runtime : $RUNTIME"

# Premier type de simulateur disponible parmi ceux donnés
device_type() {
    local name id
    for name in "$@"; do
        id=$(xcrun simctl list devicetypes -j | jq -r --arg n "$name" '.devicetypes[] | select(.name == $n) | .identifier')
        if [ -n "$id" ]; then
            echo "Simulateur : $name" >&2
            echo "$id"
            return 0
        fi
    done
    echo "Aucun simulateur disponible parmi : $*" >&2
    return 1
}

# Retire le canal alpha (refusé par App Store Connect)
remove_alpha() {
    local file
    for file in "$OUT"/*/*/*.png; do
        if sips -g hasAlpha "$file" | grep -q 'yes'; then
            sips -s format jpeg -s formatOptions best "$file" --out "$file.jpg" >/dev/null
            sips -s format png "$file.jpg" --out "$file" >/dev/null
            rm "$file.jpg"
        fi
    done
}

shoot() {
    local family="$1"
    shift
    local type udid
    type=$(device_type "$@")
    udid=$(xcrun simctl create "Thiercelieux $family" "$type" "$RUNTIME")
    log "Démarrage du simulateur $family ($udid)"
    sim 600 bootstatus "$udid" -b >/dev/null
    log "Simulateur démarré"
    sim 60 status_bar "$udid" override --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
        --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100 || true

    SCREENSHOT_DIR="$OUT/$family" flutter drive -d "$udid" \
        --driver=test_driver/screenshots.dart \
        --target=integration_test/screenshots_test.dart
    log "Captures $family terminées"

    sim 120 shutdown "$udid" || true
    sim 120 delete "$udid" || true
}

# Tailles acceptées par App Store Connect pour iPhone 6,1"/6,3" et iPad 12,9"/13"
check_sizes() {
    local file width height status=0
    for file in "$OUT"/*/*/*.png; do
        width=$(sips -g pixelWidth "$file" | awk '/pixelWidth/ { print $2 }')
        height=$(sips -g pixelHeight "$file" | awk '/pixelHeight/ { print $2 }')
        case "${width}x${height}" in
            1179x2556 | 2556x1179 | 1206x2622 | 2622x1206 | 2048x2732 | 2732x2048 | 2064x2752 | 2752x2064)
                echo "OK   ${width}x${height}  $file" ;;
            *)
                echo "TAILLE REFUSÉE PAR L'APP STORE ${width}x${height}  $file"
                status=1 ;;
        esac
    done
    return $status
}

shoot iphone "iPhone 17 Pro" "iPhone 16 Pro" "iPhone 15 Pro"
shoot ipad "iPad Pro 13-inch (M5)" "iPad Pro 13-inch (M4)" "iPad Pro (12.9-inch) (6th generation)"
remove_alpha
check_sizes
