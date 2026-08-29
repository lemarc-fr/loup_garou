#!/bin/bash

# ============================================================
# PARAMÈTRES
# ============================================================

racine="/Users/marc/Desktop/loup_garou/lib"
dossierSortie="/Users/marc/Desktop/loup_garou/dev_utils"

profondeur=-1   # -1 = pas de limite, 1 = un seul niveau

# Extensions à concaténer
extensionsAutorisees=(
    ".dart"
)

dossiersIgnores=(
    "node_modules"
    ".git"
    "__pycache__"
    ".venv"
    "dev_utils"
    ".idea"
    ".ruff_cache"
)

# ============================================================
# UTILITAIRES
# ============================================================

is_ignored() {
    local name="$1"

    for ignored in "${dossiersIgnores[@]}"; do
        if [[ "$name" == "$ignored" ]]; then
            return 0
        fi
    done

    return 1
}

is_extension_allowed() {
    local file="$1"
    local extension=".${file##*.}"

    for allowed in "${extensionsAutorisees[@]}"; do
        if [[ "$extension" == "$allowed" ]]; then
            return 0
        fi
    done

    return 1
}

# ============================================================
# GÉNÉRATION DE L'ARBORESCENCE
# ============================================================

generate_tree() {
    local path="$1"
    local prefix="$2"
    local currentDepth="$3"
    local maxDepth="$4"

    if [[ "$maxDepth" -ne -1 && "$currentDepth" -ge "$maxDepth" ]]; then
        return
    fi

    local entries=()

    while IFS= read -r -d '' entry; do
        local name
        name="$(basename "$entry")"

        if ! is_ignored "$name"; then
            entries+=("$entry")
        fi
    done < <(
        find "$path" -mindepth 1 -maxdepth 1 -print0 |
        sort -z
    )

    local count=${#entries[@]}
    local i=0

    for entry in "${entries[@]}"; do

        local name
        name="$(basename "$entry")"

        local isLast=false

        if [[ "$i" -eq $((count - 1)) ]]; then
            isLast=true
        fi

        if [[ "$isLast" == true ]]; then
            printf "%s└── %s\n" "$prefix" "$name"
        else
            printf "%s├── %s\n" "$prefix" "$name"
        fi

        if [[ -d "$entry" ]]; then

            local newPrefix

            if [[ "$isLast" == true ]]; then
                newPrefix="${prefix}    "
            else
                newPrefix="${prefix}│   "
            fi

            generate_tree \
                "$entry" \
                "$newPrefix" \
                "$((currentDepth + 1))" \
                "$maxDepth"
        fi

        i=$((i + 1))
    done
}

# ============================================================
# GÉNÉRATION DE LA CONCATÉNATION
# ============================================================

generate_concatenation() {
    local rootPath="$1"
    local outputFile="$2"
    local maxDepth="$3"

    if [[ ! -d "$rootPath" ]]; then
        echo "Le dossier spécifié n'existe pas : $rootPath"
        return
    fi

    rm -f "$outputFile"
    touch "$outputFile"

    local fichiers=()

    while IFS= read -r -d '' fichier; do

        # ----------------------------------------------------
        # Vérification extension
        # ----------------------------------------------------

        if ! is_extension_allowed "$fichier"; then
            continue
        fi

        # ----------------------------------------------------
        # Vérification profondeur
        # ----------------------------------------------------

        if [[ "$maxDepth" -ne -1 ]]; then

            local relativePath
            relativePath="${fichier#$rootPath/}"

            local depth
            depth=$(awk -F/ '{print NF}' <<< "$relativePath")

            if [[ "$depth" -gt "$maxDepth" ]]; then
                continue
            fi
        fi

        # ----------------------------------------------------
        # Vérification dossiers ignorés
        # ----------------------------------------------------

        local ignored=false

        IFS='/' read -ra parts <<< "${fichier#$rootPath/}"

        for part in "${parts[@]}"; do
            if is_ignored "$part"; then
                ignored=true
                break
            fi
        done

        if [[ "$ignored" == true ]]; then
            continue
        fi

        fichiers+=("$fichier")

    done < <(
        find "$rootPath" -type f -print0 |
        sort -z
    )

    if [[ ${#fichiers[@]} -eq 0 ]]; then
        echo "Aucun fichier trouvé à concaténer dans la profondeur spécifiée."
        return
    fi

    echo "Nombre de fichiers à concaténer : ${#fichiers[@]}"

    for fichier in "${fichiers[@]}"; do

        local cheminRelatif
        cheminRelatif="${fichier#$rootPath/}"

        {
            echo
            echo "===== Fichier: $cheminRelatif ====="
            echo
        } >> "$outputFile"

        if ! cat "$fichier" >> "$outputFile"; then
            echo "Erreur lecture fichier : $fichier"
        fi

    done

    echo "Concaténation complétée avec succès dans : $outputFile"
}

# ============================================================
# MAIN
# ============================================================

main() {

    if [[ ! -d "$racine" ]]; then
        echo "Le répertoire spécifié n'existe pas : $racine"
        return 1
    fi

    mkdir -p "$dossierSortie"

    local cheminArborescence
    cheminArborescence="$dossierSortie/arborescence.txt"

    {
        echo "$racine"
        generate_tree "$racine" "" 0 "$profondeur"
    } > "$cheminArborescence"

    echo "Arborescence enregistrée avec succès dans : $cheminArborescence"

    local cheminConcatenation
    cheminConcatenation="$dossierSortie/concatenation.txt"

    generate_concatenation \
        "$racine" \
        "$cheminConcatenation" \
        "$profondeur"
}

main