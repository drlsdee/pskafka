<#
.SYNOPSIS
    The function gets a value of the "KAFKA_HOME" environment variable and returns it, if the path is valid. Otherwise it returns nothing.
.DESCRIPTION
    The function gets a value of the "KAFKA_HOME" environment variable and returns it, if the path is valid. Otherwise it returns nothing.
.EXAMPLE
    PS C:\> Get-KafkaHomeEnv
    The function gets a value of the environment variable "KAFKA_HOME" and returns it, if the path is valid. Otherwise it returns nothing.
.OUTPUTS
    System.String
#>

function Get-KafkaHomeEnv {
    [CmdletBinding()]
    [OutputType([string])]
    param   ()
    end     {
        #   Get the environment variable "KAFKA_HOME":
        [string]$outputPath =   [System.Environment]::GetEnvironmentVariable('KAFKA_HOME')
        #   The variable does not exist or contains an empty string; return nothing:
        if  ([string]::IsNullOrEmpty($outputPath) -or [string]::IsNullOrWhiteSpace($outputPath))    {   return  }
        #   The variable contains a valid directory path; return it immediately:
        if  ([System.IO.Directory]::Exists($outputPath))    {   return  $outputPath }
        #   The variable contains a valid FILE path; return the parent directory path:
        if  ([System.IO.File]::Exists($outputPath)) {   return  [System.IO.FileInfo]::new($outputPath).DirectoryName    }
        #   The variable contains a path that does not exist; return nothing:
        return
    }
}