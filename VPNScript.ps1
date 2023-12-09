# Self-elevate the script to admin if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $CommandLine
        Exit
    }
}

# edit the registry
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent"
$valName = "AssumeUDPEncapsulationContextOnSendRule"
$val = 00000002

Write-Output "`nEditing registry settings necessary for the VPN..." 
if (-NOT (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}  

New-ItemProperty -Path $regPath -Name $valName -Value $val -PropertyType DWORD -Force
Start-Sleep -Seconds 2

# add the VPN
$vpnName = "" # insert vpn name here
$servAddress = "" # insert vpn server address here
$vpnType = "L2TP" 
$psk = "" # insert vpn password here
$encryption = "Optional"
$rasphone = "C:\ProgramData\Microsoft\Network\Connections\Pbk\rasphone.pbk"

Write-Output "`nCreating the VPN..." 
if (Test-Path -Path $rasphone) {
    Write-Output "`nVPN connection '$vpnName' already exists. Deleting and remaking the connection..."
    Remove-Item -Path $rasphone -Force
}

Add-VpnConnection -Name $vpnName -ServerAddress $servAddress -TunnelType $vpnType -AllUserConnection -L2tpPsk $psk -AuthenticationMethod PAP, CHAP, MSCHAPv2 -EncryptionLevel $encryption -SplitTunneling -Force -PassThru
Start-Sleep -Seconds 3.5

# modify VPN IPv4 settings by changing the pbk file directly
Write-Output "`nConfiguring VPN Settings..."
(Get-Content $rasphone) -Replace "IpInterfaceMetric=0", "IpInterfaceMetric=1" | Set-Content $rasphone
Start-Sleep -Seconds 2

Write-Output "`nResetting Execution Policy to restricted..."
Remove-Item -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\ -Force
Start-Sleep -Seconds 2

$restart = Read-Host "`nA restart is required to finish setting up the VPN. Restart now? (y/n)"
if ($restart -eq "Y" -or $restart -eq "y") {
    shutdown /r /t 0 /f
} else {
    Write-Output "`nMake sure to restart the machine before you attempt to connect to VPN!"
}

