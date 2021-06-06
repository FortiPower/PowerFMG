#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-FMGRestMethod {

    <#
      .SYNOPSIS
      Invoke RestMethod with FMG connection (internal) variable

      .DESCRIPTION
      Invoke RestMethod with FMG connection variable (session)

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "pm/config/global/obj/firewall/address"

      Invoke-RestMethod with FMG connection for get pm/config/global/obj/firewall/address uri

      .EXAMPLE
      Invoke-FMGRestMethod "pm/config/global/obj/firewall/address"

      Invoke-RestMethod with FMG connection for get pm/config/global/obj/firewall/address uri with default parameter

      .EXAMPLE
      Invoke-FMGRestMethod "-method "get" -uri "pm/config/global/obj/firewall/address" -vdom vdomX

      Invoke-RestMethod with FMG connection for get pm/config/global/obj/firewall/address uri on vdomX

      .EXAMPLE
      Invoke-FMGRestMethod --method "post" -uri "pm/config/global/obj/firewall/address" -body $body

      Invoke-RestMethod with FMG connection for post pm/config/global/obj/firewall/address uri with $body payload

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "pm/config/global/obj/firewall/addresss" -connection $fw2

      Invoke-RestMethod with $fw2 connection for get pm/config/global/obj/firewall/address uri

    #>

    [CmdletBinding(DefaultParameterSetName = "default")]
    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("GET", "SET", "ADD", "UPDATE", "DELETE", "CLONE", "EXEC")]
        [String]$method = "GET",
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [psobject]$connection
    )

    Begin {
    }

    Process {

        if ($null -eq $connection ) {
            if ($null -eq $DefaultFMGConnection) {
                Throw "Not Connected. Connect to the Fortigate with Connect-FMG"
            }
            $connection = $DefaultFMGConnection
        }

        $Server = $connection.Server
        $port = $connection.port
        $headers = $connection.headers
        $invokeParams = $connection.invokeParams
        $sessionvariable = $connection.websession

        $fullurl = "https://${Server}:${port}/jsonrpc"

        #Make params data (with uri and data)
        $params = @{
            #data = $body
            url = $uri
        }

        #Make Invoke-RestMethod body query
        $irm_body = @{
            id = $connection.id++
            method = $method
            session = $connection.session
            verbose = 1
            params = @($params)
        }

        try {
            Write-Verbose -message ($irm_body | ConvertTo-Json -Depth 10)

            $response = Invoke-RestMethod $fullurl -Method "POST" -body ($irm_body | ConvertTo-Json -Depth 10 -Compress) -Headers $headers -WebSession $sessionvariable @invokeParams
        }

        catch {
            Show-FMGException $_
            throw "Unable to use FortiGate API"
        }

        #Check status code
        if ($response.result.status.code -ne "0") {
            throw "Unable to use FortiManager API (" + $response.result.status.code + ") " + $response.result.status.message
        }
        $response.result.data

    }

}