<#
Author: Chris Morland
Description: Test for LogCleanUp.ps1 which verifies the script works as expected.
Dependencies: This test requires the latest version of the Pester Module on a Windows Machine
#>

Param(
    [parameter(Mandatory = $True, Position = 0)]
    $LogFolderPath,
    [parameter(Mandatory = $True, Position = 1)]
    $DaysArchiveAfter,
    [parameter(Mandatory = $True, Position = 2)]
    $DaysDeleteAfter
)

Import-Module Pester -Force

.$PSscriptroot\LogCleanUp.ps1 -LogFolderPath $LogFolderPath -DaysArchiveAfter $DaysArchiveAfter -DaysDeleteAfter $DaysDeleteAfter

$ArchiveFolderExists = Test-Path $LogFolderPath\_Archive

$LogFolderResults = Get-ChildItem -Path $LogFolderPath | 
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$DaysArchiveAfter)}

$DeleteArchiveResults = Get-ChildItem -Path $LogFolderPath\_Archive |
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays( - $DaysDeleteAfter)}   

Describe 'Archive and Delete Logs Test' -Tags 'Archive and Delete Logs Test' {
    It '_Archive Folder Exists' -test {
        $ArchiveFolderExists | Should -Be $True
    }

    It 'NothingToArchive' -test {
        $LogFolderResults | Should -Be $null
    }

    It 'NothingToDelete' -test {
        $DeleteArchiveResults | Should -Be $null
    }
}
