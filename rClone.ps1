Import-Module Hyper-V           # Imports Hyper-V management module for PoSH
 
$date = Get-Date -Format yyyy-MM-dd         # Gets current date for filename and path purposes
$path = "C:\Exports\$date"              # Sets the export location to include the date
 
Start-Transcript -Path "C:\Scripts\Logs\ScheduledHyperClone-$date.txt" #starts transcription of the console
 
$allVMs = Get-VM               # Retrieves all VM's to be exported
 
Write-Output "Testing if export path exists..."
if (!(Test-Path $path))         # Determines whether the export location exists
{
    New-Item $path -Type Directory              # Creates path if it doesnt exist
    Write-Output "Export path did not exist, it has been created at $path"
}
else
{
    Write-Output "Beginning rclone"
 
	$CMD = 'rclone.exe'
	$arg1 = 'move'
	$arg2 = '--transfers=7'
	$arg3 = '--stats=10m'
	$arg4 = $path
	$arg5 = 'gdrive:HyperAuto'
	$arg6 = $date
	$arg7 = '-q'
	
	&$CMD $arg1 $arg2 $arg3 $arg4 $arg5'\'$arg6 $arg7
    #Write-Output $($arg1 + ' ' + $arg2 + ' ' + $arg3 + ' ' + $arg4 + ' ' + $arg5 + '' + '\' + $arg6)
 
    Write-Output "rclone completed, rcloned the following files:"
   
	$arg1 = "lsd"
	$arg2 = "gdrive:HyperAuto"
	$arg3 = "$date"
	&$CMD $arg1 $arg2'\'$arg3
    Write-Output "Backup complete."
}
 
Write-Output "Export path exists, moving on to exports."           #
 
foreach ($VM in $allVMs)
{
    Write-Output "Attempting to export the VM $($VM.VMName)"
    Export-VM -Path $path -Name $VM.VMName -ErrorAction "SilentlyContinue"               # exports the job with the paremeters defined above
}    
   
Write-Output "Waiting for all exports to finish.."
   
$vmstatus = Get-VM | select secondaryoperationalstatus
while ($vmstatus -like "*export*")
{
    Start-Sleep 30
    Write-Output 'Waiting'
    $vmstatus = Get-VM | select secondaryoperationalstatus
}
 
$successfulExports = gci $path                  # Gets a list of all items in the export folder and lists them
Write-Output "Successfully exported the following VMs;"
Write-Output "$successfulExports"
 
Write-Output "Beginning rclone"
 
$CMD = 'rclone.exe'
$arg1 = 'move'
$arg2 = '--transfers=7'
$arg3 = '--stats=10m'
$arg4 = $path
$arg5 = 'gdrive:HyperAuto'
$arg6 = $date
$arg7 = '-q'
 
#& $CMD $($arg1 + ' ' + $arg2 + ' ' + $arg3 + ' ' + $arg4 + ' ' + $arg5 + '' + '\' + $arg6)
&$CMD $arg1 $arg2 $arg3 $arg4 $arg5'\'$arg6 $arg7
 
Write-Output "rclone completed, rcloned the following files:"
   
$arg8 = "lsd"
$arg9 = "gdrive:HyperAuto"
$arg10 = $date
&$CMD $arg8 $arg9'/'$arg10
Write-Output "Backup complete."

Stop-Transcript  #stops the transcripting of the logs

break