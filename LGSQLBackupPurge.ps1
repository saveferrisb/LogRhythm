# -----------------------------------------------
# (C) December 22, 2017
# Author: Shoestring
# Description:  
# As LogRhythm backups may be scheduled to run daily, these consist of very large files which may consume large amounts of disk space 
# eventually causing backups to fail as a result. This PS script can be integrated into the LogRhythm backup process to purge files >= 14 days old.


# This script is to be imported as a step into LogRhythm Backup as a job. Place this at step 1 or at the last step.
# As step 1, this will delete old backups first prior to backing up the latest databases from the SIEM.
# If you prefer to backup first, then insert this as the last step.
# To do this open up the Job Activity Monitor from Microsoft SQL Server Management Studio and select LogRhythm backup.


######## Very Important!!, add your path to LogRhythm DB backups here ########
$FromPath = "< change this to your backup path>"

# Change offset to specify number of days to your liking, 14 is default.
$Offset = 14	

# Create a folder that corresponds to your desired logpath.			
$LogPath = "C:\LogRhythm\PowerShellLogs\"

							
$DateStamp = get-date -uformat "%Y-%m-%d %T"

# -----------------------------------------------
# deleteFiles method
# -----------------------------------------------
function deleteFiles
{

	$count = 0
	#$dirs = Get-ChildItem $FromPath | Where-Object {$_.PSIsContainer -eq $True}
	#$dirs | Where-Object {$_.GetDirectories().Count -eq 0} | 
	Get-ChildItem $FromPath $_.FullName |
	foreach {
		try 
		{
			
			#Checks if last write date of file and todays date - offset (14) days
			if ($_.LastWriteTime -lt (Get-date).AddDays(-$Offset))
			{
				if(!(Test-Path $_.FullName -PathType Container)) # if the file is not a folder then remove it.
				{
					Remove-Item $_.FullName -Force; 
					write-output "$DateStamp : $_ Deleted";
					write-output "$DateStamp : $_ Deleted" | Out-File -FilePath $LogPath\PurgeLog.txt -Append;
					$count++;
				}
			}
			else
			{
				if(Test-Path $_.FullName -PathType Container) # we don't delete folders, so tell the user that the object is not a file.
				{
					write-output "$DateStamp : $_ is a folder";
					# write-output "$DateStamp : $_ is a folder" | Out-File -FilePath $LogPath\PurgeLog.txt -Append; 
				}
				else # file age is within the offset.
				{
					write-output "$DateStamp : $_ left alone";
					write-output "$DateStamp : $_ left alone." | Out-File -FilePath $LogPath\PurgeLog.txt -Append; 
				}	
			}
		}
		catch 
		{
			$errormessage = $_.Exception.Message
			write-output "$DateStamp : $DateStamp : $errormessage" | Out-File -FilePath $LogPath\PurgeLog.txt -Append;
		}
	}
	write-output "$DateStamp : Number of files removed: $count";
	write-output "$DateStamp : Number of files removed: $count`n" | Out-File -FilePath $LogPath\PurgeLog.txt -Append;

}
	deleteFiles
