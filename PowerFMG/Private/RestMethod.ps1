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
      Invoke-FMGRestMethod -method "get" -uri "pm/config/adom/root/obj/firewall/address"

      Invoke-RestMethod with FMG connection for get pm/config/adom/root/obj/firewall/address uri

      .EXAMPLE
      Invoke-FMGRestMethod "pm/config/global/obj/firewall/address"

      Invoke-RestMethod with FMG connection for get pm/config/adom/root/obj/firewall/address uri with default parameter

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "pm/config/adom/root/obj/firewall/address" -vdom vdomX

      Invoke-RestMethod with FMG connection for get pm/config/adom/root/obj/firewall/address uri on vdomX

      .EXAMPLE
      Invoke-FMGRestMethod -method "post" -uri "pm/config/adom/root/obj/firewall/address" -body $body

      Invoke-RestMethod with FMG connection for post pm/config/adom/root/obj/firewall/address uri with $body payload

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "pm/config/adom/root/obj/firewall/address" -connection $fw2

      Invoke-RestMethod with $fw2 connection for get pm/config/adom/root/obj/firewall/address uri

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "pm/config/adom/root/obj/firewall/address" -filter @('name', '==', 'FMG')

      Invoke-RestMethod with FMG connection for get pm/config/adom/root/obj/firewall/address uri with only name equal FMG

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "pm/config/adom/root/obj/firewall/address" -filter_attribute name -filter_value FMG

      Invoke-RestMethod with FMG connection for get pm/config/adom/root/obj/firewall/address uri with filter attribute equal name and filter value equal FMG

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "pm/config/adom/root/obj/firewall/address" -filter_attribute name -filter_type contains -filter_value FMG

      Invoke-RestMethod with FMG connection for get pm/config/adom/root/obj/firewall/address uri with filter attribute equal name and filter value contains FMG

      .EXAMPLE
      Invoke-FMGRestMethod -method "get" -uri "firewall/address" -type pm

      Invoke-RestMethod with FMG connection for get firewall/address uri with set the adom from $DefaultFMGConnection (add pm/config/adom/XXX/obj to uri)
    #>

    [CmdletBinding(DefaultParameterSetName = "default")]
    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("get", "set", "add", "update", "delete", "clone", "exec", IgnoreCase = $false)]
        [String]$method = "get",
        [Parameter(Mandatory = $false)]
        [ValidateSet("pm", "cli", "sys", "dvm", "dvmdb")]
        [String]$type,
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter (ParameterSetName = "filter")]
        [array]$filter,
        [Parameter(Mandatory = $false)]
        [Parameter (ParameterSetName = "filter_build")]
        [string]$filter_attribute,
        [Parameter(Mandatory = $false)]
        [ValidateSet('equal', 'contains')]
        [Parameter (ParameterSetName = "filter_build")]
        [string]$filter_type,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter_build")]
        [psobject]$filter_value,
        [Parameter(Mandatory = $false)]
        [psobject]$connection
    )

    Begin {
    }

    Process {

        if ($null -eq $connection ) {
            if ($null -eq $DefaultFMGConnection) {
                Throw "Not Connected. Connect to the FortiManager with Connect-FMG"
            }
            $connection = $DefaultFMGConnection
        }

        $Server = $connection.Server
        $port = $connection.port
        $headers = $connection.headers
        $invokeParams = $connection.invokeParams
        $sessionvariable = $connection.websession

        $fullurl = "https://${Server}:${port}/jsonrpc"

        switch ($type) {
            'pm' {
                $url = "pm/config"
                #if you set the global ADOM...
                if ($connection.adom -eq "global") {
                    $url += "/global/obj/" + $uri
                }
                else {
                    $url += "/adom/" + $connection.adom + "/obj/" + $uri
                }
            }
            Default {
                $url = $uri
            }
        }

        #filter
        $afilter = @()
        switch ( $filter_type ) {
            "equal" {
                $afilter += ("==")
                $afilter += ($filter_value)
            }
            "contains" {
                $afilter += ("contain")
                $afilter += ($filter_value)
            }
            "like" {
                $afilter += ("like")
                $afilter += ("%" + $filter_value + "%")
            }
            #by default set to equal..
            default {
                $afilter += ("==")
                $afilter += ($filter_value)
            }
        }

        if ($filter_attribute) {
            $filter = @($filter_attribute) + $afilter
        }

        #Make params data (with uri, data, filter...)
        $params = @{
            url = $url
        }
        if ($body) {
            $params.data = $body
        }
        if ($filter) {
            $params.filter = $filter
        }
        #Make Invoke-RestMethod body query
        $irm_body = @{
            id      = $connection.id++
            method  = $method
            session = $connection.session
            verbose = 1
            params  = @($params)
        }

        try {
            Write-Verbose -message ($irm_body | ConvertTo-Json -Depth 10)

            $response = Invoke-RestMethod $fullurl -Method "POST" -body ($irm_body | ConvertTo-Json -Depth 10 -Compress) -Headers $headers -WebSession $sessionvariable @invokeParams
        }

        catch {
            Show-FMGException $_
            throw "Unable to use FortiManager API"
        }

        #Check status code
        if ($response.result.status.code -ne "0") {
            throw "Unable to use FortiManager API (" + $response.result.status.code + ") " + $response.result.status.message
        }
        $response.result.data

    }

}