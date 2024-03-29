# NOTE: Run this command in Powershell if you get the script execution policy error:  Set-ExecutionPolicy RemoteSigned

param ( 
[string]$ScriptFolder = "C:\Development\SqlScripts\MSP_Dashboard\", 
[string]$Server = "webw12srv01", 
[string]$Database = "MSP_Dashboard"
) 
  
 $SqlScripts = $ScriptFolder + "vw_*.sql"
 $LogFile = $ScriptFolder + "SqlCmd.log"
  
(dir $SqlScripts) |  
  ForEach-Object {  
        
    $Message = Get-Date -format g
    $Message = $Message + " -  $_..."
    $Message | Out-File -FilePath $LogFile -Append
    Write-Host $Message
    
    SQLCMD -S $Server -E -i $_.FullName -d $Database >> $LogFile
   }