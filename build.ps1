# Пакует lists/*.txt в родной формат mihomo (.mrs).
# Ядро mihomo должно лежать в bin/mihomo.exe (https://github.com/MetaCubeX/mihomo/releases).
$mihomo = Join-Path $PSScriptRoot "bin/mihomo.exe"
foreach ($src in Get-ChildItem (Join-Path $PSScriptRoot "lists") -Filter *.txt) {
    $out = [IO.Path]::ChangeExtension($src.FullName, ".mrs")
    & $mihomo convert-ruleset domain text $src.FullName $out
    if ($LASTEXITCODE -ne 0) { throw "не удалось собрать $($src.Name)" }
    Write-Host "$($src.Name) -> $([IO.Path]::GetFileName($out))"
}
