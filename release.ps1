# JIGU AdBlock 릴리즈 스크립트
#
# 사용법:
#   .\release.ps1 -Version 0.3.0
#
# 동작:
#   1. F:\jigu_adblock\manifest.json 의 version 을 새 값으로 갱신
#   2. Chrome 으로 CRX 패킹 (같은 키 사용)
#   3. releases\jigu_adblock-X.X.X.crx 저장
#   4. update.xml 갱신 (버전 + URL)
#   5. git commit + push (GitHub 자동 배포)

param(
  [Parameter(Mandatory=$true)]
  [string]$Version
)

$ErrorActionPreference = 'Stop'

$srcDir = "F:\jigu_adblock"
$relDir = "F:\jigu_adblock_releases"
$keyPath = "$relDir\key.pem"
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$extId = (Get-Content "$relDir\extension_id.txt" -Raw).Trim()

Write-Host "=== JIGU MODE Release v$Version ==="
Write-Host ""

# 1) manifest.json 버전 갱신 (한글 안 깨지게 raw text 치환)
Write-Host "[1] Updating manifest.json version..."
$manifestPath = "$srcDir\manifest.json"
$raw = Get-Content $manifestPath -Raw -Encoding UTF8
$oldMatch = [regex]::Match($raw, '"version"\s*:\s*"([^"]+)"')
$oldVer = $oldMatch.Groups[1].Value
$newRaw = [regex]::Replace($raw, '"version"\s*:\s*"[^"]+"', "`"version`": `"$Version`"", 1)
# UTF-8 BOM 없이 저장
[System.IO.File]::WriteAllText($manifestPath, $newRaw, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "    $oldVer -> $Version"

# 2) Chrome 으로 패킹
Write-Host "[2] Packing CRX..."
& $chrome --pack-extension="$srcDir" --pack-extension-key="$keyPath" | Out-Null
Start-Sleep -Seconds 2

$tempCrx = "F:\jigu_adblock.crx"
if (-not (Test-Path $tempCrx)) {
  Write-Host "ERROR: Pack failed. $tempCrx not found." -ForegroundColor Red
  exit 1
}

$newCrx = "$relDir\releases\jigu_adblock-$Version.crx"
Move-Item -Force $tempCrx $newCrx
Write-Host "    Saved: $newCrx"

# 3) update.xml 갱신
Write-Host "[3] Updating update.xml..."
$updateXml = @"
<?xml version='1.0' encoding='UTF-8'?>
<gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
  <app appid='$extId'>
    <updatecheck codebase='https://raw.githubusercontent.com/leejigu96-stack/jigu_adblock/main/releases/jigu_adblock-$Version.crx' version='$Version'/>
  </app>
</gupdate>
"@
Set-Content "$relDir\update.xml" $updateXml -Encoding UTF8 -NoNewline
Write-Host "    update.xml updated"

# 4) git 커밋 + push
Write-Host "[4] Committing to git..."
Push-Location $relDir
try {
  git add releases/ update.xml | Out-Null
  git commit -m "Release v$Version" | Out-Null
  git push origin main
  Write-Host "    Pushed to GitHub"
} catch {
  Write-Host "    Git push failed (먼저 GitHub repo 초기 셋업했나?)" -ForegroundColor Yellow
}
Pop-Location

Write-Host ""
Write-Host "=== Done. Chrome will auto-update within 5 hours. ==="
Write-Host "수동 트리거: chrome://extensions -> 우상단 'Update' 버튼"
