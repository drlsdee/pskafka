<#
.SYNOPSIS
    The function gets the command name (currently "kcat" or "kafkacat") and returns a path to the directory containing the binary.
.DESCRIPTION
    The function gets the command name (currently "kcat" or "kafkacat") and returns a path to the directory containing the binary.
    If the command is not found, the function returns nothing. If more than one command is found, the function returns the path for the latest version.
.EXAMPLE
    PS C:\> Get-KafkaHomeCmd
    The function returns the path to the directory containing the "kcat" executable.
    If the command is not found, the function returns nothing. If more than one command is found, the function returns the path for the latest version.
.EXAMPLE
    PS C:\> Get-KafkaHomeCmd -Name kcat
    The function returns the path to the directory containing the "kcat" executable.
    If the command is not found, the function returns nothing. If more than one command is found, the function returns the path for the latest version.
.EXAMPLE
    PS C:\> Get-KafkaHomeCmd -Name kafkacat
    The function returns the path to the directory containing the "kafkacat" executable.
    If the command is not found, the function returns nothing. If more than one command is found, the function returns the path for the latest version.
.INPUTS
    System.String
.OUTPUTS
    System.String
#>

function Get-KafkaHomeCmd {
    [CmdletBinding()]
    [OutputType([string])]
    param   (
        [Parameter(Position=1)]
        [ValidateSet('kafkacat','kcat')]
        [string]$Name   =   'kcat'
    )
    end {
        #   Try to get command info
        try {
            [System.Management.Automation.ApplicationInfo[]]$cmdInfo    =   Get-Command -Name $Name -ErrorAction Stop
        }
        catch {
            $cmdInfo    =   @()
        }
        #   Nothing found; so return nothing:
        if  ($cmdInfo.Count -eq 0)  {   return  }
        #   Only one command found; return the path
        if  ($cmdInfo.Count -eq 1)  {   return  [System.IO.FileInfo]::new($cmdInfo[0].Source).DirectoryName }
        #   More than one command found; return the latest version
        [System.Management.Automation.ApplicationInfo]$cmdLatest    =   ($cmdInfo | Sort-Object -Property Version -Descending)[0]
        return  [System.IO.FileInfo]::new($cmdLatest.Source).DirectoryName
    }
}