$libPath = "lib\screens"
$files = Get-ChildItem -Path $libPath -Recurse -Filter "*.dart"

$pairs = @(
  @("0xFF0F172A", "0xFF14375E"),
  @("0xFF1E293B", "0xFF1E6091"),
  @("0xFF2563EB", "0xFF1E6091"),
  @("0xFF1D4ED8", "0xFF1E6091"),
  @("0xFF1E3A8A", "0xFF1E6091"),
  @("0xFF1E40AF", "0xFF1E6091"),
  @("0xFFF8FAFC", "0xFFFFFFFF"),
  @("0xFFF8F6F2", "0xFFEDF1F9"),
  @("0xFF334155", "0xFF6B7A99"),
  @("0xFF475569", "0xFF6B7A99"),
  @("0xFF5F6C7B", "0xFF6B7A99"),
  @("0xFF1B1B1B", "0xFF14375E"),
  @("0xFFE8EEF6", "0xFFEDF1F9"),
  @("0xFFE1E5EA", "0xFFDDE3EF"),
  @("0xFFF2F5FA", "0xFFEDF1F9")
)

foreach ($file in $files) {
  $content = [System.IO.File]::ReadAllText($file.FullName)
  $original = $content
  foreach ($pair in $pairs) {
    $content = $content.Replace($pair[0], $pair[1])
  }
  if ($content -ne $original) {
    [System.IO.File]::WriteAllText($file.FullName, $content)
    Write-Host "Updated: $($file.Name)"
  }
}
Write-Host "All done."
