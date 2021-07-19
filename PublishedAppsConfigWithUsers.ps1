#Author: Wayne Groenendaal
#Date: 28/05/2021
#Use: Inventory XenDesktop Site published application config and output to csv file

#Records current variable value
$FormatEnumerationLimitOld=$FormatEnumerationLimit

#Sets variable to unlimited
$FormatEnumerationLimit=-1

#Sets the location
set-location $PSScriptRoot

#Sets static variables
$tempdir = "C:\Temp"

#Loads Citrix Modules
asnp citrix*
$DeliveryGroups = Get-BrokerDesktopGroup
$Applications = Get-BrokerApplication
#Retrieves Site name
$SiteName =  Get-BrokerSite | Select-Object -ExpandProperty Name

$AppList = @()

foreach ($App in $Applications) {
    foreach ($DG in $DeliveryGroups) {
        if ($App.AssociatedDesktopGroupUids -match $DG.Uid) {
            $Report = New-Object -TypeName psobject
            $Report | Add-Member -MemberType NoteProperty -Name ApplicationName -Value $App.Name
            $Report | Add-Member -MemberType NoteProperty -Name ApplicationType -Value $App.ApplicationType
            $Report | Add-Member -MemberType NoteProperty -Name Description -Value $App.Description
            $Report | Add-Member -MemberType NoteProperty -Name DeliveryGroupName -Value $DG.Name
            $Report | Add-Member -MemberType NoteProperty -Name AssociatedUserNames -Value $App.AssociatedUserNames
            $Report | Add-Member -MemberType NoteProperty -Name CommandLineExecutable -Value $App.CommandLineExecutable
            $Report | Add-Member -MemberType NoteProperty -Name CommandLineArguments -Value $App.CommandLineArguments
            $Report | Add-Member -MemberType NoteProperty -Name WorkingDirectory -Value $App.WorkingDirectory
            $Report | Add-Member -MemberType NoteProperty -Name Enabled -Value $App.Enabled
            $Report | Add-Member -MemberType NoteProperty -Name PublishedName -Value $App.PublishedName
            $Report | Add-Member -MemberType NoteProperty -Name ClientFolder -Value $App.ClientFolder
            $Report | Add-Member -MemberType NoteProperty -Name Tags -Value $App.Tags
            $Report | Add-Member -MemberType NoteProperty -Name BrowserName -Value $App.BrowserName
            $Report | Add-Member -MemberType NoteProperty -Name AdminFolderName -Value $App.AdminFolderName
            $AppList += $Report
        }
    }
}

#Tests temp location, if doesn't exist, creates temp directory.
$Temp = test-path $tempdir
while("True" -notcontains $Temp)
{
    write-host
    write-host "$tempdir directory doesn't exist." -ForegroundColor Red
    write-host "Attempting to create Temp directory on C:\" -ForegroundColor Magenta
    new-item $tempdir -itemtype directory > $null
    $Temp = test-path $tempdir
    write-host
}

$AppList | Select ApplicationName,Description,DeliveryGroupName,@{l="AssociatedUserNames";e={$_.AssociatedUserNames -join ","}},CommandLineExecutable,CommandLineArguments,WorkingDirectory,Enabled,PublishedName,ClientFolder,@{l="Tags";e={$_.Tags -join ","}},BrowserName,AdminFolderName | Export-Csv -NoTypeInformation C:\temp\$SiteName"_PublishedAppsConfigWithUsers"$(get-date -f dd-MM-yyyy-HH-mm).csv 

#Sets the variable back to the original value
$FormatEnumerationLimit=$FormatEnumerationLimitOld
