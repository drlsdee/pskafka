<#
.SYNOPSIS
    The function gets an input string and returns it, if the string is a valid path.
.DESCRIPTION
    The function gets an input string and returns it, if the string is a valid path.
.EXAMPLE
    PS C:\> Get-KafkaHomeDef
    The function returns nothing.
.EXAMPLE
    PS C:\> Get-KafkaHomeDef -Default ".\default\kafka\path"
    If the specified path exists, the function returns it. Otherwise it returns nothing.
.INPUTS
    System.String
.OUTPUTS
    System.String
#>

function Get-KafkaHomeDef {
    [CmdletBinding()]
    [OutputType([string])]
    param   (
        [Parameter(Position=1)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Default
    )
    end     {
        #   Resolve full path
        try {
            $Default    =   Resolve-Path -Path $Default -ErrorAction Stop
        }
        catch {
            $Default    =   $null
        }
        #   The string is empty; return nothing:
        if  ([string]::IsNullOrEmpty($Default) -or [string]::IsNullOrWhiteSpace($Default))  {   return  }
        #   The directory exists; return the path:
        if  ([System.IO.Directory]::Exists($Default))   {   return  $Default    }
        #   The file exists; return the parent path:
        if  ([System.IO.File]::Exists($Default))   {   return  [System.IO.FileInfo]::new($Default).DirectoryName    }
        #   Neither file nor directory exists; return nothing:
        return
    }
}