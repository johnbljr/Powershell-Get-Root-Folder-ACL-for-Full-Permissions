<#
------------------------------------------------------------
Author: John Leger
Date: March 5, 2019
Powershell Version Built/Tested on: 5.1
Title: Get Root Folder ACL for Full Permissions
Website: https://github.com/johnbljr
License: GNU General Public License v3.0
------------------------------------------------------------
#>  

#Search Path
$path = "E:\"

#Excluded users
$ExcludeUsers = 'domain\Domain Admins','NT AUTHORITY\SYSTEM'
$ExcludeUsersRegex = ($ExcludeUsers | ForEach-Object { [regex]::Escape($_) }) -join '|'


Get-Childitem $path -depth 0 -Directory | ForEach-Object {
    $file = $_

    Get-Acl -Path $file.FullName |
    Select-Object -ExpandProperty Access |
    Where-Object {$_.IdentityReference -notmatch $ExcludeUsersRegex -and $_.AccessControlType -eq "Allow" -and $_.FileSystemRights -eq "FullControl"} |
    ForEach-Object {
        #Foreach ACL
        New-Object psobject -Property @{
            Path = $file.FullName
            ACL = $_.IdentityReference
        }
    }
} | Select-Object -Property Path, ACL | Export-Csv c:\temp\FolderACL.csv -NoTypeInformation