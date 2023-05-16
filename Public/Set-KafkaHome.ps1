<#
.SYNOPSIS
    Sets the `KAFKA_HOME` environment variable for the session.
.DESCRIPTION
    Sets the `KAFKA_HOME` environment variable for the session.
    A longer description of the function, its purpose, common use cases, etc.
.PARAMETER Path
	The value to set `KAFKA_HOME`. If the string is null or empty, the variable will be cleared.
.EXAMPLE
    Set-KafkaHome '~/kafka' # to use Kafka CLI
    Set-KafkaHome $null     # to revert to kafkacat
.INPUTS
    System.String
    System.EnvironmentVariableTarget
.OUTPUTS
    System.String
.NOTES
#>

function Set-KafkaHome {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param(
        [Parameter(Position=1)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Path,
        [Parameter(Position=2)]
        [Alias('Target')]
        [System.EnvironmentVariableTarget]$Scope = [System.EnvironmentVariableTarget]::Process,
        #	If this parameter is specified, the cmdlet returns the processed objects. Normally the cmdlet does not returns anything.
        [Parameter()]
        [switch]
        $PassThru
    )
    end {
        #   The path is specified; try to resolve it
        if  (-not   [string]::IsNullOrEmpty($Path)) {
            $Path   =   Get-KafkaHomeDef -Default $Path
            if  ([string]::IsNullOrEmpty($Path))    {   #   The specified path is not found!
                throw [System.IO.DirectoryNotFoundException]::new($Path)
            }
        }
        #   Set the environment variable
        [string]$variableName   =   'KAFKA_HOME'
        [string]$valueOld   =   [System.Environment]::GetEnvironmentVariable($variableName)
        if  (
            ($Scope -eq [System.EnvironmentVariableTarget]::Machine) -or `  #   Machine-wide scope
            (-not [string]::IsNullOrEmpty($valueOld))                       #   The value is already pesent and may be overwritten
        )    {
            $ConfirmPreference  =   [System.Management.Automation.ConfirmImpact]::High
        }
        [string]$ifSPTarget     =   'name="{0}", value="{1}", target="{2}"; old value: "{3}"' -f  $variableName, $Path, $Scope, $valueOld
        [string]$ifSPOperation  =   '[System.Environment]::SetEnvironmentVariable()'
        if  ($PSCmdlet.ShouldProcess($ifSPTarget, $ifSPOperation)) {
            try {
                [System.Environment]::SetEnvironmentVariable($variableName, $Path, $Scope)
            }
            catch {
                throw $_
            }
        }
        if  (-not $PassThru)    {   return  }
        return  $Path
    }

    <# if ($Path) {
        if (-not (Test-Path $Path)) {
            throw [System.IO.DirectoryNotFoundException]::new($Path)
        }
    }
    [System.Environment]::SetEnvironmentVariable('KAFKA_HOME', $Path, $Scope) #>
}