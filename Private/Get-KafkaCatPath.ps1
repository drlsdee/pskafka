<#
.SYNOPSIS
    The function returns the full path to the kcat/kafkacat binary, if it is present in the current environment.
.DESCRIPTION
    The function returns the full path to the kcat/kafkacat binary, if it is present in the current environment.
    The function looks for the file with name "kcat" (which is primary option) or "kafkacat" (last option) in the Kafka home directory.
    If the file is present, the function returns this path. If not, the function throws an exception.
.EXAMPLE
    PS C:\> Get-KafkaCatPath
    The function returns the full path to the kcat/kafkacat binary, if present in the current environment.
    Firstly, the function looks for a file named "kcat". If the file is present, the function returns its path.
    If not, the function falls back to the old name, "kafkacat" and looks for this.
    If neither kcat nor kafkacat were found, the function throws an exception.
.EXAMPLE
    PS C:\> Get-KafkaCatPath -Name kcat
    The function returns the full path to the kcat/kafkacat binary, if present in the current environment.
    Firstly, the function looks for a file named "kcat". If the file is present, the function returns its path.
    If not, the function falls back to the old name, "kafkacat" and looks for this.
    If neither kcat nor kafkacat were found, the function throws an exception.
.EXAMPLE
    PS C:\> Get-KafkaCatPath -Name kafkacat
    The function returns the full path to the file named "kafkacat", if the file is present in the current environment. If not, the function throws an exception.
.INPUTS
    System.String
.OUTPUTS
    System.String
#>

function Get-KafkaCatPath {
    [CmdletBinding()]
    param   (
        [Parameter(Position=1)]
        [ValidateSet('kafkacat','kcat')]
        [string]$Name   =   'kcat'
    )
    end     {
        #   Kafka home directory
        [string]$kafkaHome  =   Get-KafkaHome -ErrorAction Stop
        #   Path to the executable
        [string]$kafkaPath  =   [System.IO.Path]::Combine($kafkaHome,$Name)
        #   Append the ".exe" extension for Windows
        #   About this enumeration: see https://learn.microsoft.com/ru-ru/dotnet/api/system.platformid
        #   TL;DR: this is the only valid value for Windows platform on which PowerShell scripts may run
        if  ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) {
            [string]$kafkaPath  =   [System.IO.Path]::ChangeExtension($kafkaPath,'.exe')
        }
        #   Test the resulting path and return it, if found:
        if  ([System.IO.File]::Exists($kafkaPath))  {   return  $kafkaPath  }
        #   The file not found; evaluate the "Name" parameter value:
        if  ($Name -ieq 'kafkacat') {   #   The "kafkacat" is the last possible value; if the file not found, it means there are no kcat/kafkacat instances in well-known places
            throw [System.IO.FileNotFoundException]::new('The file not found!', $kafkaPath)
        }
        #   Call this function recursively
        Get-KafkaCatPath -Name kafkacat -ErrorAction Stop
    }
}