<#
.DESCRIPTION
        Attempts to find the ideal Kafka CLI to use.

        If the environment variable `KAFKA_HOME` is set, it is used;
        else if the `-Default` parameter is given, it is used;
        else if a `kafkacat` executable exists in PATH, it is used;
        else, the (hopefully) appropriate `kafkacat` instance shipped with pskafka is used.
#>

<#
.SYNOPSIS
    Attempts to find the ideal Kafka CLI to use.
.DESCRIPTION
    Attempts to find the ideal Kafka CLI to use.
    If the environment variable `KAFKA_HOME` is set, it is used;
    else if the `-Default` parameter is given, it is used;
    else if a `kafkacat` executable exists in PATH, it is used;
    else, the (hopefully) appropriate `kafkacat` instance shipped with pskafka is used.
.EXAMPLE
    PS C:\> Get-KafkaHome
    If the environment variable "KAFKA_HOME" is specified, the function returns its value; then tries to find the "kafkacat" or "kcat" commands in system default paths; and finally returns the path to the binary shipped with this module.
.EXAMPLE
    PS C:\> Get-KafkaHome -Default ".\default\kafka\path"
    If the specified path exists, the function returns it.
    If the environment variable "KAFKA_HOME" is specified, the function returns its value; then tries to find the "kafkacat" or "kcat" commands in system default paths; and finally returns the path to the binary shipped with this module.
.INPUTS
    System.String
.OUTPUTS
    System.String
.NOTES
    Attempts to find the ideal Kafka CLI to use.
    If the environment variable `KAFKA_HOME` is set, it is used;
    else if the `-Default` parameter is given, it is used;
    else if a `kafkacat` executable exists in PATH, it is used;
    else, the (hopefully) appropriate `kafkacat` instance shipped with pskafka is used.
.LINK
    https://github.com/fresh2dev/pskafka#readme
#>


function Get-KafkaHome {
    [CmdletBinding()]
    param(
        [Parameter(Position=1)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Default
    )
    end {
        #   The "Default" parameter was specified; try to resolve it and return the result
        [string]$pathDef    =   Get-KafkaHomeDef -Default $Default
        #   The default path exists; immediately return the path; the end of the function
        if  (-not [string]::IsNullOrEmpty($pathDef)) {  return  $pathDef    }
        #   1st, let's try to get the environment variable:
        [string]$pathEnv    =   Get-KafkaHomeEnv
        #   The variable exists and has a valid value; immediately return the path; the end of the function
        if  (-not [string]::IsNullOrEmpty($pathEnv)) {  return  $pathEnv    }
        #   Try to get the command path
        [string]$pathCmdNew =   Get-KafkaHomeCmd -Name kcat
        #   The command exists; immediately return the path; the end of the function
        if  (-not [string]::IsNullOrEmpty($pathCmdNew)) {  return  $pathCmdNew  }
        [string]$pathCmdOld =   Get-KafkaHomeCmd -Name kafkacat
        #   The command exists; immediately return the path; the end of the function
        if  (-not [string]::IsNullOrEmpty($pathCmdOld)) {  return  $pathCmdOld  }
        #   Finally, return the path to the binary shipped with this module
        if      ($IsLinux)  {   [string]$osDir  =   'deb'   }
        elseif  ($IsMacOS)  {   [string]$osDir  =   'mac'   }
        else <# Windows #>  {   [string]$osDir  =   'win'   }
        [string]$moduleBase     =   [System.IO.DirectoryInfo]::new($PSScriptRoot).Parent.FullName
        [string]$pathShipped    =   [System.IO.Path]::Combine($moduleBase,'bin',$osDir)
        if  (-not [System.IO.Directory]::Exists($pathShipped))  {
            throw [System.IO.DirectoryNotFoundException]::new("The path does not exist: '$pathShipped'")
        }
        return  $pathShipped
    }
    <# $path = [System.Environment]::GetEnvironmentVariable('KAFKA_HOME')

    if ($path) {
        $path = $path
    }
    elseif ($Default) {
        $path = $Default
    }
    else {
        [string]$path = Get-Command 'kafkacat' -ErrorAction 'SilentlyContinue' | Select-Object -ExpandProperty Path
        
        if ($path) {
            $path = Split-Path $path -Parent
        }
        else {
            [string]$os_dir = $null

            if ($IsLinux) {
                $os_dir = 'deb'
            }
            elseif ($IsMacOS) {
                $os_dir = 'mac'
            }
            else { #if ($IsWindows) {
                $os_dir = 'win'
            }

            $path = [System.IO.Path]::Combine((Get-Module 'pskafka').ModuleBase, 'bin', $os_dir)
        }
    }

    return $($path | Resolve-Path | Select-Object -ExpandProperty Path) #>
}