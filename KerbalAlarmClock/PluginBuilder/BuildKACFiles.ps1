﻿param([String]$VersionString = $(throw "-VersionString is required so we know what folder to build.`r`n`r`n"))

#Run by powershell BuildKACFiles.ps1 -VersionString "X.X.X.X"

$SourcePath= "D:\Programming\KSP\KerbalAlarmClock\DevBranch-20Legacy\Source"
$DestRootPath="D:\Programming\KSP\KerbalAlarmClockUpload"
$DestFullPath= "$($DestRootPath)\v$($VersionString)"
$7ZipPath="c:\Program Files\7-Zip\7z.exe" 

"This will build v$($VersionString) of the Kerbal Alarm Clock"
"`tFrom:`t$($SourcePath)"
"`tTo:`t$($DestFullPath)"
$Choices= [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes","&No")
$ChoiceRtn = $host.ui.PromptForChoice("Do you wish to Continue?","This will erase any existing $($VersionString) Folder",$Choices,1)

if($ChoiceRtn -eq 0)
{
    "Here Goes..."

    if(Test-Path -Path $DestFullPath)
    {
        "Deleting $DestFullPath"
        Remove-Item -Path $DestFullPath -Recurse

    }

    #Create the folders
    "Creating Folders..."
    New-Item $DestRootPath -name "v$($VersionString)" -ItemType Directory

    #Dont create this or it will copy the files into a subfolder
    #New-Item $DestFullPath -name "KerbalAlarmClock_$($VersionString)" -ItemType Directory
    New-Item $DestFullPath -name "KerbalAlarmClockSource_$($VersionString)" -ItemType Directory

    #Copy the items 
    "Copying Plugin..."
    Copy-Item "$SourcePath\PluginFiles" "$($DestFullPath)\KerbalAlarmClock_$($VersionString)" -Recurse
    Copy-Item "$SourcePath\bin\Debug\KerbalAlarmClock.dll" "$($DestFullPath)\KerbalAlarmClock_$($VersionString)\Plugins" 
    #Update the Text files with the version String
    (Get-Content "$($DestFullPath)\KerbalAlarmClock_$($VersionString)\info.txt") |
        ForEach-Object {$_ -replace "%VERSIONSTRING%",$VersionString} |
            Set-Content "$($DestFullPath)\KerbalAlarmClock_$($VersionString)\info.txt"
    (Get-Content "$($DestFullPath)\KerbalAlarmClock_$($VersionString)\ReadMe.txt") |
        ForEach-Object {$_ -replace "%VERSIONSTRING%",$VersionString} |
            Set-Content "$($DestFullPath)\KerbalAlarmClock_$($VersionString)\ReadMe.txt"

    #Copy the source files
    "Copying Source..."
    Copy-Item "$SourcePath\*.cs"  "$($DestFullPath)\KerbalAlarmClockSource_$($VersionString)"
    Copy-Item "$SourcePath\*.csproj"  "$($DestFullPath)\KerbalAlarmClockSource_$($VersionString)"
    New-Item "$DestFullPath\KerbalAlarmClockSource_$($VersionString)\" -name "Properties" -ItemType Directory
    Copy-Item "$SourcePath\Properties\*.cs" "$($DestFullPath)\KerbalAlarmClockSource_$($VersionString)\Properties\"
    

    # Now Zip it up

    & "$($7ZipPath)" a "$($DestFullPath)\KerbalAlarmClock_$($VersionString).zip" "$($DestFullPath)\KerbalAlarmClock_$($VersionString)" 
    & "$($7ZipPath)" a "$($DestFullPath)\KerbalAlarmClockSource_$($VersionString).zip" "$($DestFullPath)\KerbalAlarmClockSource_$($VersionString)" 
}

else
{
    "Skipping..."
}

