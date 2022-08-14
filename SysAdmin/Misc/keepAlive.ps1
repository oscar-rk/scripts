# Keep machine alive

Clear-Host
Echo "Keep Alive with Scroll Lock..."

$wait = 240 # <- Time in seconds until key is pressed again.
$pressAgain = 100 # <- Time in milliseconds until key is pressed back again (so it's always in it's initial state).
$WShell = New-Object -com "Wscript.Shell"

while ($true)
{
  $WShell.sendkeys("{SCROLLLOCK}")
  Start-Sleep -Milliseconds $pressAgain
  $WShell.sendkeys("{SCROLLLOCK}")
  Start-Sleep -Seconds $wait
}
