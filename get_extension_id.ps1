# PEM 키에서 Chrome 확장 ID 계산
$pemPath = "F:\jigu_adblock_releases\key.pem"

Add-Type -AssemblyName System.Security

$pem = Get-Content $pemPath -Raw

# RSA 객체 생성 → public key 얻기
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
$rsa.ImportFromPem($pem)
$pubKey = $rsa.ExportSubjectPublicKeyInfo()

# SHA256 hash
$sha = [System.Security.Cryptography.SHA256]::Create()
$hash = $sha.ComputeHash($pubKey)

# 앞 16 바이트 (32 hex chars) → a-p 매핑 (Chrome 확장 ID 규칙)
$hex = -join ($hash[0..15] | ForEach-Object { $_.ToString("x2") })
$id = -join ($hex.ToCharArray() | ForEach-Object {
  $c = $_.ToString()
  if ($c -match '[0-9]') {
    [char]([int][char]'a' + [int]$c)
  } else {
    [char]([int][char]'a' + ([int][char]$c - [int][char]'a'))
  }
})

Write-Host "Extension ID: $id"
$id | Out-File -FilePath "F:\jigu_adblock_releases\extension_id.txt" -NoNewline -Encoding ASCII
