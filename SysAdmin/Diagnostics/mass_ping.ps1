Clear-Host

$Machines = Get-Content "machines.txt"

foreach($Machine in $Machines){
	$Answer = Test-Connection -ComputerName $Machine -Count 1 -ErrorAction SilentlyContinue

		if($Answer){
			Write-Host "$Machine is online" -ForegroundColor Green
		}else{
			Write-Host "$Machine is offline" -ForegroundColor Red
		}
}