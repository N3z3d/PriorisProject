# Script de lancement Prioris - Port dynamique (8080-8090)
Write-Host "🚀 Lancement de Prioris..." -ForegroundColor Cyan

# Chercher le premier port libre entre 8080 et 8090
$freePort = $null
for ($p = 8080; $p -le 8090; $p++) {
    $inUse = Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue
    if (-not $inUse) {
        $freePort = $p
        break
    }
}

if (-not $freePort) {
    Write-Host "❌ Aucun port libre entre 8080 et 8090." -ForegroundColor Red
    exit 1
}

Write-Host "🌐 Port sélectionné : $freePort" -ForegroundColor Cyan

# Ne plus fermer Brave automatiquement
Write-Host "🌐 Brave restera ouvert si déjà lancé" -ForegroundColor Blue

# Attendre un peu avant de lancer Flutter
Start-Sleep -Seconds 1

# Lancer Flutter sur Edge (plus fiable que Windows desktop)
Write-Host "🌐 Lancement de Flutter sur Edge port $freePort..." -ForegroundColor Green

try {
    # Lancer Flutter
    flutter run -d edge --web-port $freePort --web-browser-flag="--new-window"
} catch {
    Write-Host "❌ Erreur lors du lancement de Flutter" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Après le lancement de Flutter, ouvrir Brave sur l'URL
Start-Sleep -Seconds 5
try {
    $braveExe = Get-Command "brave.exe" -ErrorAction SilentlyContinue
    if ($braveExe) {
        Start-Process "brave.exe" "http://localhost:$freePort" -WindowStyle Normal
        Write-Host "🎯 Brave lancé sur http://localhost:$freePort" -ForegroundColor Magenta
    } else {
        Write-Host "⚠️ Brave non trouvé. Utilisez Edge : http://localhost:$freePort" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Impossible de lancer Brave. Utilisez Edge : http://localhost:$freePort" -ForegroundColor Yellow
}

Write-Host "✨ Prioris démarré sur http://localhost:$freePort" -ForegroundColor Green 