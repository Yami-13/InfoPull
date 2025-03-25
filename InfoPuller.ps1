# Checks if script is ran as admin + closes if not (Supposed to ask to be elevated.)
#Requires -RunAsAdministrator

# Establishes Username for current user and changes directory to users documents folder
$username = $env:USERNAME
cd "C:\Users\$username\Documents"

# Code that requires administrator privileges goes here
#Establishes folders for efficient storage of information (Ensure folders of same name DO NOT exist before running)
New-Item -ItemType Directory -Path ".\InformationPulled"
New-Item -ItemType Directory -Path ".\InformationPulled\Firewall"
New-Item -ItemType Directory -Path ".\InformationPulled\RegKeys"
New-Item -ItemType Directory -Path ".\InformationPulled\EventLogs"

# Exports firewall rules into xml file.
Get-NetFirewallRule | Select-Object Name, DisplayName, Enabled, Direction, Action, Profile, LocalPort, RemotePort, Protocol, LocalAddress, RemoteAddress, Program | Export-Csv -Path ".\InformationPulled\Firewall\FirewallRules.csv" -NoTypeInformation

# Export run and run once registry key in .reg format
#reg export HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run .\HKEY_Local_Run_BkUp.reg -y
#reg export HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce .\HKEY_Local_RunOnce_BkUp.reg -y
#reg export HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run .\HKEY_Current_User_Run_BkUp.reg -y
#reg export HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce .\HKEY_Current_User_RunOnce_BkUp.reg -y

# Export run and run once keys to csv (maybe)
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Export-Csv -Path ".\InformationPulled\RegKeys\HKLM_run.csv" -NoTypeInformation
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" | Export-Csv -Path ".\InformationPulled\RegKeys\HKLM_runOnce.csv" -NoTypeInformation
Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Export-Csv -Path ".\InformationPulled\RegKeys\HKCU_run.csv" -NoTypeInformation
Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" | Export-Csv -Path ".\InformationPulled\RegKeys\HKCU_runOnce.csv" -NoTypeInformation

# Export logon logoff event logs
$eventIDs = 4611, 4624, 4648, 4776, 4778, 4643, 4779 # Replace with the desired Event IDs
$logName = "Security" # Replace with the desired log name, e.g., "System"
$outputPath = ".\InformationPulled\EventLogs\logon_logoff_events.csv" # Replace with the desired output path

Get-WinEvent -FilterHashtable @{LogName=$logName; ID=$eventIDs} | 
  Select-Object TimeCreated, ID, LevelDisplayName, ProviderName, Message |
  Export-Csv -Path $outputPath -NoTypeInformation

# Export privelege usage
$eventIDs = 4672, 4673, 4674, 4703, 4768, 4769, 4771 # Replace with the desired Event IDs
$logName = "Security" # Replace with the desired log name, e.g., "System"
$outputPath = ".\InformationPulled\EventLogs\privilege_events.csv" # Replace with the desired output path

Get-WinEvent -FilterHashtable @{LogName=$logName; ID=$eventIDs} | 
  Select-Object TimeCreated, ID, LevelDisplayName, ProviderName, Message |
  Export-Csv -Path $outputPath -NoTypeInformation

# Export process executed and terminated
$eventIDs = 4688, 4689 # Replace with the desired Event IDs
$logName = "Security" # Replace with the desired log name, e.g., "System"
$outputPath = ".\InformationPulled\EventLogs\process_executed_terminated_events.csv" # Replace with the desired output path

Get-WinEvent -FilterHashtable @{LogName=$logName; ID=$eventIDs} | 
  Select-Object TimeCreated, ID, LevelDisplayName, ProviderName, Message |
  Export-Csv -Path $outputPath -NoTypeInformation

# Export policy changes
$eventIDs = 4670, 4904, 4905, 4946, 4947 # Replace with the desired Event IDs
$logName = "Security" # Replace with the desired log name, e.g., "System"
$outputPath = ".\InformationPulled\EventLogs\policy_change_events.csv" # Replace with the desired output path

Get-WinEvent -FilterHashtable @{LogName=$logName; ID=$eventIDs} | 
  Select-Object TimeCreated, ID, LevelDisplayName, ProviderName, Message |
  Export-Csv -Path $outputPath -NoTypeInformation

# Export powershell and command line executions and (potentially) usage
$eventIDs = 400, 403, 4104, 600, 4688, 500 # Replace with the desired Event IDs
$logName = "Security" # Replace with the desired log name, e.g., "System"
$outputPath = ".\InformationPulled\EventLogs\powershell_commandline_events.csv" # Replace with the desired output path

Get-WinEvent -FilterHashtable @{LogName=$logName; ID=$eventIDs} | 
  Select-Object TimeCreated, ID, LevelDisplayName, ProviderName, Message |
  Export-Csv -Path $outputPath -NoTypeInformation

#Allows user to see end of script + sleeps for a little so they can actually read it.
Write-Output "The extracted files are available within your 'Documents' folder!"
Start-Sleep -Seconds 5
