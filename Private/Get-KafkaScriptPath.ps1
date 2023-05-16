<#
.SYNOPSIS
    The function returns a path to the native Kafka script, if present in the current environment
.DESCRIPTION
    The function returns a path to the native Kafka script, if present in the current environment
.EXAMPLE
    PS C:\> Get-KafkaScriptPath -Mode Consumer
    The function returns a path to the native Kafka script "kafka-console-consumer.sh" or "kafka-console-consumer.bat", if present in the current environment
.EXAMPLE
    PS C:\> Get-KafkaScriptPath -Mode Producer
    The function returns a path to the native Kafka script "kafka-console-producer.sh" or "kafka-console-producer.bat", if present in the current environment
.EXAMPLE
    PS C:\> Get-KafkaScriptPath -Mode Topics
    The function returns a path to the native Kafka script "kafka-topics.sh" or "kafka-topics.bat", if present in the current environment
.INPUTS
    System.String
.OUTPUTS
    System.String
#>

function Get-KafkaScriptPath {
    [CmdletBinding()]
    [OutputType([string])]
    param   (
        [Parameter(Mandatory,Position=1)]
        [ValidateSet('Consumer','Producer','Topics')]
        [string]$Mode,
        [Parameter()]
        [switch]$Win32
    )
    end     {
        #   Kafka home directory
        [string]$kafkaHome  =   Get-KafkaHome -ErrorAction Stop
        switch  ($Mode) {
            'Consumer'  { [string]$scriptName   =   'kafka-console-consumer'}
            'Producer'  { [string]$scriptName   =   'kafka-console-producer'}
            'Topics'    { [string]$scriptName   =   'kafka-topics'          }
            #Default     {   }
        }
        #   Create path
        if  ($Win32)    {
            [string]$kafkaPath  =   [System.IO.Path]::ChangeExtension( [System.IO.Path]::Combine($kafkaHome, 'bin', 'windows', $scriptName), '.bat' )
        }
        else {
            [string]$kafkaPath  =   [System.IO.Path]::ChangeExtension( [System.IO.Path]::Combine($kafkaHome, 'bin', $scriptName), '.sh' )
        }
        #   Test path and return if present
        if  ([System.IO.File]::Exists($kafkaPath))  {   return  $kafkaPath  }
        #   return nothing
        return
    }
}