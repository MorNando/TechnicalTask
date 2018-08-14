<#
Author: Chris Morland
Description: This is a script to archive log files older than a certain date, then delete older than another date
Created: 13/08/2018
Version: 1.0

Change Log:
None

Dependencies: Minimum of PowerShell Version 5 to be run on a Windows operating system
#>
Param(
    [parameter(Mandatory = $True, Position = 0)]
    $LogFolderPath,
    [parameter(Mandatory = $True, Position = 1)]
    $DaysArchiveAfter,
    [parameter(Mandatory = $True, Position = 2)]
    $DaysDeleteAfter
)

Start-Transcript -Path $PSScriptRoot\LastRunTranscript.log

Function Remove-ArchiveLogs{

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $True, Position = 0)]
        [String]$LogFolderPath,
        [parameter(Mandatory= $True, Position = 1)]
        [int]$DaysDeleteAfter
    )

    $ArchivesToRemove = Get-ChildItem -Path $LogFolderPath -File -Recurse | 
        Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$DaysDeleteAfter) } 

    if ($ArchivesToRemove -ne $Null){
        $ArchivesToRemove | 
            remove-item -Force -Confirm:$False -Verbose
    }
    else{
        Write-Verbose -Message 'No archives to delete. Up to date'
    }

}

Function Start-CompressFiles {

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$True,Position=0)]
        [string]$LogFolderPath,
        [parameter(Mandatory=$True,Position=1)]
        [int]$DaysArchiveAfter
    )

    if((Test-Path $LogFolderPath\_Archive) -ne $True){

        New-Item -Path $LogFolderPath -Name _Archive -ItemType "Directory" -Confirm:$false | Out-Null
        Write-Verbose -Message "Created _Archive folder at $LogFolderPath"

    }
    $Date = Get-Date -Format dd-MM-yyyyTHH-mm
    
    $ToArchive = Get-ChildItem -Path $LogFolderPath -File | 
        Where-Object { ( $_.CreationTime -lt (Get-Date).AddDays( -$DaysArchiveAfter) ) -and ($_.Extension -ne '.zip') }

    If($ToArchive -ne $Null){

       $ToArchive | 
            Compress-Archive -DestinationPath "$LogFolderPath\_Archive\Archive_$Date.zip" -CompressionLevel Optimal -Verbose
       
       $ToArchive | 
            Remove-Item -Force -Verbose | Out-Null
    }
    else {
        Write-Verbose -Message 'Nothing to archive. Up to date'
    }
    
    Get-ChildItem -Path $LogFolderPath -Filter *.zip | Move-Item -Destination $LogFolderPath\_Archive
}

Start-CompressFiles -LogFolderPath $LogFolderPath -DaysArchiveAfter $DaysArchiveAfter -Verbose

Remove-ArchiveLogs -LogFolderPath $LogFolderPath -DaysDeleteAfter $DaysDeleteAfter -Verbose

Stop-Transcript
