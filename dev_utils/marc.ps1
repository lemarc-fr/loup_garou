$racine = "C:\Users\marcb\StudioProjects\loup_garou\lib"
$dossierSortie = "C:\Users\marcb\StudioProjects\loup_garou\dev_utils"
$profondeur = -1   # -1 = pas de limite, 1 = un seul niveau
$dossiersIgnores = @("node_modules", ".git", "__pycache__", ".venv", 'dev_utils', '.idea', '.ruff_cache')

function Generate-Tree {
    param (
        [string]$Path,
        [string]$Prefix = "",
        [int]$CurrentDepth = 0,
        [int]$MaxDepth = -1
    )

    if ($MaxDepth -ne -1 -and $CurrentDepth -ge $MaxDepth) {
        return ""
    }

    $treeOutput = ""
    $entries = Get-ChildItem -LiteralPath $Path | Where-Object { $dossiersIgnores -notcontains $_.Name } | Sort-Object Name
    for ($i = 0; $i -lt $entries.Count; $i++) {
        $entry = $entries[$i]
        $isLast = ($i -eq $entries.Count - 1)

        if ($entry.PSIsContainer) {
            $line = if ($isLast) {
                "$Prefix└── $($entry.Name)`n"
            } else {
                "$Prefix├── $($entry.Name)`n"
            }
            $treeOutput += $line

            $newPrefix = $Prefix + ($(if ($isLast) { "    " } else { "│   " }))
            $treeOutput += Generate-Tree -Path $entry.FullName -Prefix $newPrefix -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
        } else {
            $line = if ($isLast) {
                "$Prefix└── $($entry.Name)`n"
            } else {
                "$Prefix├── $($entry.Name)`n"
            }
            $treeOutput += $line
        }
    }

    return $treeOutput
}
function Generate-Concatenation {
    param (
        [string]$RootPath,
        [string]$OutputFile,
        [int]$MaxDepth = -1
    )
    $extensionsAutorisees = @(
       ".dart"
    )

    if (-not (Test-Path $RootPath)) {
        Write-Host "Le dossier spécifié n'existe pas : $RootPath" -ForegroundColor Red
        return
    }

    # Supprimer le fichier s’il existe déjà
    if (Test-Path $OutputFile) {
        Remove-Item -Path $OutputFile -Force -ErrorAction SilentlyContinue
    }

    # Créer un fichier vide
    New-Item -ItemType File -Path $OutputFile -Force | Out-Null

    # Calcul de la profondeur de chaque fichier
    $rootDepth = ($RootPath.TrimEnd("\") -split '\\').Count

    $fichiers = Get-ChildItem -Path $RootPath -File -Recurse | Where-Object {
        $extensionsAutorisees -contains $_.Extension.ToLower()
    } | Where-Object {
        if ($MaxDepth -eq -1) { return $true }
        $fileDepth = ($_.FullName -split '\\').Count
        return ($fileDepth - $rootDepth) -le $MaxDepth
    } | Where-Object {
    $parts = $_.FullName -split '\\'
    -not ($parts | Where-Object { $dossiersIgnores -contains $_ })
    }

    if ($fichiers.Count -eq 0) {
        Write-Host "Aucun fichier trouvé à concaténer dans la profondeur spécifiée." -ForegroundColor Yellow
        return
    }

    Write-Host "Nombre de fichiers à concaténer : $($fichiers.Count)" -ForegroundColor Cyan

    foreach ($fichier in $fichiers) {
        $cheminRelatif = $fichier.FullName.Substring($RootPath.Length).TrimStart("\")
        Add-Content -Path $OutputFile -Value "`n===== Fichier: $cheminRelatif =====`n"
        try {
            Get-Content -LiteralPath $fichier.FullName | Add-Content -LiteralPath $OutputFile
        } catch {
            Write-Host "Erreur lecture fichier : $($fichier.FullName) - $_" -ForegroundColor Red
        }
    }

    Write-Host "Concaténation complétée avec succès dans : $OutputFile" -ForegroundColor Green
}


function Main {
    param (
        [string]$racine,
        [string]$dossierSortie,
        [int]$profondeur = -1
    )

    if (-not (Test-Path $racine -PathType Container)) {
        Write-Host "Le répertoire spécifié n'existe pas : $racine" -ForegroundColor Red
        return
    }

    # Génération de l'arborescence
    $arborescence = Generate-Tree -Path $racine -MaxDepth $profondeur
    $cheminArborescence = Join-Path -Path $dossierSortie -ChildPath "arborescence.txt"

    try {
        "$racine`n$arborescence" | Out-File -FilePath $cheminArborescence -Encoding UTF8
        Write-Host "Arborescence enregistrée avec succès dans : $cheminArborescence" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de l'enregistrement de l'arborescence : $_" -ForegroundColor Red
    }

    # Génération de la concaténation
    $cheminConcatenation = Join-Path -Path $dossierSortie -ChildPath "concatenation.txt"
    Generate-Concatenation -RootPath $racine -OutputFile $cheminConcatenation -MaxDepth $profondeur
}

# === PARAMÈTRES D'EXÉCUTION ===


Main -racine $racine -dossierSortie $dossierSortie -profondeur $profondeur