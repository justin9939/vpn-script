# VPN Script usage guide
I created this script as a co-op project for Canada's Michael Smith Genome Sciences Centre (GSC) while I was working there as a Client Support Technician. Its purpose is to automate the process of connecting to the GSC VPN while working remotely, speeding it up considerably and minimizing user error. Since the aforementioned VPN is an L2TP connection, the script is designed primarily for such VPNs. 

The fields "$vpnName," "$servAddress," and "$psk" (password search key) are left blank to be filled as necessary for whatever VPN connection you intend to create.

Before running the script, run "SetExecutionPolicy.reg" to temporarily change your Windows machine's execution policy to unrestricted to allow the script to properly run. Once the VPN is created and configured, the script will automatically set the execution policy to "restricted" to prevent any other unauthorized scripts from running. Restart your machine after running .reg files for the changes made to take effect.

To run the script itself, left-click "VPNScript.ps1" and click "Run with PowerShell." The output on the PowerShell terminal will inform you of its progress. If there are any errors, simply rerun the script - it will delete the VPN and recreate it. If the issues persist, manually removing the VPN from Windows Settings will resolve them.

After the script runs, make sure to restart your machine again, as the registry was changed to restricted.
