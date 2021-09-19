#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copy from PowerFGT.. :)
#
# SPDX-License-Identifier: Apache-2.0
#
function Add-FMGFirewallAddress {

    <#
        .SYNOPSIS
        Add a Firewall Address

        .DESCRIPTION
        Add a Firewall Address (ipmask, iprange, fqdn)

        .EXAMPLE
        Add-FMGFirewallAddress -Name FMG -ip 192.0.2.0 -mask 255.255.255.0

        Add Address object type ipmask with name FMG and value 192.0.2.0/24

        .EXAMPLE
        Add-FMGFirewallAddress -Name FMG -ip 192.0.2.0 -mask 255.255.255.0 -interface port2

        Add Address object type ipmask with name FMG, value 192.0.2.0/24 and associated to interface port2

        .EXAMPLE
        Add-FMGFirewallAddress -Name FMG -ip 192.0.2.0 -mask 255.255.255.0 -comment "My FMG Address"

        Add Address object type ipmask with name FMG, value 192.0.2.0/24 and a comment

        .EXAMPLE
        Add-FMGFirewallAddress -Name FMG -ip 192.0.2.0 -mask 255.255.255.0 -visibility:$false

        Add Address object type ipmask with name FMG, value 192.0.2.0/24 and disabled visibility

        .EXAMPLE
        Add-FMGFirewallAddress -Name FortiPower -fqdn fortipower.github.io

        Add Address object type fqdn with name FortiPower and value fortipower.github.io

        .EXAMPLE
        Add-FMGFirewallAddress -Name FMG-Range -startip 192.0.2.1 -endip 192.0.2.100

        Add Address object type iprange with name FMG-Range with start IP 192.0.2.1 and end ip 192.0.2.100
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter (Mandatory = $false, ParameterSetName = "fqdn")]
        [string]$fqdn,
        [Parameter (Mandatory = $false, ParameterSetName = "ipmask")]
        [ipaddress]$ip,
        [Parameter (Mandatory = $false, ParameterSetName = "ipmask")]
        [ipaddress]$mask,
        [Parameter (Mandatory = $false, ParameterSetName = "iprange")]
        [ipaddress]$startip,
        [Parameter (Mandatory = $false, ParameterSetName = "iprange")]
        [ipaddress]$endip,
        [Parameter (Mandatory = $false)]
        [string]$interface,
        [Parameter (Mandatory = $false)]
        [ValidateLength(0, 255)]
        [string]$comment,
        [Parameter (Mandatory = $false)]
        [boolean]$visibility,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFMGConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }

        if ( Get-FMGFirewallAddress @invokeParams -name $name -connection $connection) {
            Throw "Already an address object using the same name"
        }

        $uri = "firewall/address"

        $address = new-Object -TypeName PSObject

        $address | add-member -name "name" -membertype NoteProperty -Value $name

        switch ( $PSCmdlet.ParameterSetName ) {
            "ipmask" {
                $address | add-member -name "type" -membertype NoteProperty -Value "ipmask"
                $subnet = $ip.ToString()
                $subnet += "/"
                $subnet += $mask.ToString()
                $address | add-member -name "subnet" -membertype NoteProperty -Value $subnet
            }
            "iprange" {
                $address | add-member -name "type" -membertype NoteProperty -Value "iprange"
                $address | add-member -name "start-ip" -membertype NoteProperty -Value $startip.ToString()
                $address | add-member -name "end-ip" -membertype NoteProperty -Value $endip.ToString()
            }
            "fqdn" {
                $address | add-member -name "type" -membertype NoteProperty -Value "fqdn"
                $address | add-member -name "fqdn" -membertype NoteProperty -Value $fqdn
            }
            default { }
        }

        if ( $PsBoundParameters.ContainsKey('interface') ) {
            #TODO check if the interface (zone ?) is valid
            $address | add-member -name "associated-interface" -membertype NoteProperty -Value $interface
        }

        if ( $PsBoundParameters.ContainsKey('comment') ) {
            $address | add-member -name "comment" -membertype NoteProperty -Value $comment
        }

        if ( $PsBoundParameters.ContainsKey('visibility') ) {
            #with 6.4.x, there is no longer visibility parameter
            if ($connection.version -ge "6.4.0") {
                Write-Warning "-visibility parameter is no longer available with FortiOS 6.4.x and after"
            }
            else {
                if ( $visibility ) {
                    $address | add-member -name "visibility" -membertype NoteProperty -Value "enable"
                }
                else {
                    $address | add-member -name "visibility" -membertype NoteProperty -Value "disable"
                }
            }
        }

        Invoke-FMGRestMethod -method "add" -type "pm" -body $address -uri $uri -connection $connection @invokeParams | out-Null

        Get-FMGFirewallAddress -connection $connection @invokeParams -name $name
    }

    End {
    }
}

function Copy-FMGFirewallAddress {

    <#
        .SYNOPSIS
        Copy/Clone a Firewall Address

        .DESCRIPTION
        Copy/Clone a Firewall Address (ip, mask, comment, associated interface... )

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Copy-FMGFirewallAddress -name MyFMGAddress_copy

        Copy / Clone MyFMGAddress and name MyFMGAddress_copy

    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-FMGAddress $_ })]
        [psobject]$address,
        [Parameter (Mandatory = $true)]
        [string]$name,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFMGConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }

        $uri = "firewall/address/$($address.name)"

        $body = Get-FMGFirewallAddress -connection $connection @invokeParams -name $address.name

        $body.name = $name

        Invoke-FMGRestMethod -method "clone" -type "pm" -uri $uri -body $body -connection $connection @invokeParams | out-Null

        Get-FMGFirewallAddress -connection $connection @invokeParams -name $name
    }

    End {
    }
}

function Get-FMGFirewallAddress {

    <#
        .SYNOPSIS
        Get list of all "address"

        .DESCRIPTION
        Get list of all "address" (ipmask, iprange, fqdn...)

        .EXAMPLE
        Get-FMGFirewallAddress

        Get list of all address object

        .EXAMPLE
        Get-FMGFirewallAddress -name myFMGAddress

        Get address named myFMGAddress

        .EXAMPLE
        Get-FMGFirewallAddress -name FMG -filter_type like

        Get address like with %FMG%

        .EXAMPLE
        Get-FMGFirewallAddress -uuid 9e73a10e-1772-51ea-a8d7-297686fd7702

        Get address with uuid 9e73a10e-1772-51ea-a8d7-297686fd7702

  #>

    [CmdletBinding(DefaultParameterSetName = "default")]
    Param(
        [Parameter (Mandatory = $false, Position = 1, ParameterSetName = "name")]
        [string]$name,
        [Parameter (Mandatory = $false, ParameterSetName = "uuid")]
        [string]$uuid,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [string]$filter_attribute,
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "name")]
        [Parameter (ParameterSetName = "uuid")]
        [Parameter (ParameterSetName = "filter")]
        [ValidateSet('equal', 'contains', 'like')]
        [string]$filter_type = "equal",
        [Parameter (Mandatory = $false)]
        [Parameter (ParameterSetName = "filter")]
        [psobject]$filter_value,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFMGConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }

        switch ( $PSCmdlet.ParameterSetName ) {
            "name" {
                $filter_value = $name
                $filter_attribute = "name"
            }
            "uuid" {
                $filter_value = $uuid
                $filter_attribute = "uuid"
            }
            default { }
        }

        #if filter value and filter_attribute, add filter (by default filter_type is equal)
        if ( $filter_value -and $filter_attribute ) {
            $invokeParams.add( 'filter_value', $filter_value )
            $invokeParams.add( 'filter_attribute', $filter_attribute )
            $invokeParams.add( 'filter_type', $filter_type )
        }

        $response = Invoke-FMGRestMethod -uri 'firewall/address' -type 'pm' -method 'get' -connection $connection @invokeParams

        $response

    }

    End {
    }

}

function Set-FMGFirewallAddress {

    <#
        .SYNOPSIS
        Configure a Firewall Address

        .DESCRIPTION
        Change a Firewall Address (ip, mask, comment, associated interface... )

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Set-FMGFirewallAddress -ip 192.0.2.0 -mask 255.255.255.0

        Change MyFMGAddress to value (ip and mask) 192.0.2.0/24

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Set-FMGFirewallAddress -ip 192.0.2.1

        Change MyFMGAddress to value (ip) 192.0.2.1

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Set-FMGFirewallAddress -interface port1

        Change MyFMGAddress to set associated interface to port 1

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Set-FMGFirewallAddress -comment "My FMG Address" -visibility:$false

        Change MyFMGAddress to set a new comment and disabled visibility

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Set-FMGFirewallAddress -fqdn fortipower.github.io

        Change MyFMGAddress to set a new fqdn fortipower.github.io

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Set-FMGFirewallAddress -startip 192.0.2.100

        Change MyFMGAddress to set a new startip (iprange) 192.0.2.100

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Set-FMGFirewallAddress -endip 192.0.2.200

        Change MyFMGAddress to set a new endip (iprange) 192.0.2.200

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium', DefaultParameterSetName = 'default')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-FMGAddress $_ })]
        [psobject]$address,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false, ParameterSetName = "fqdn")]
        [string]$fqdn,
        [Parameter (Mandatory = $false, ParameterSetName = "ipmask")]
        [ipaddress]$ip,
        [Parameter (Mandatory = $false, ParameterSetName = "ipmask")]
        [ipaddress]$mask,
        [Parameter (Mandatory = $false, ParameterSetName = "iprange")]
        [ipaddress]$startip,
        [Parameter (Mandatory = $false, ParameterSetName = "iprange")]
        [ipaddress]$endip,
        [Parameter (Mandatory = $false)]
        [string]$interface,
        [Parameter (Mandatory = $false)]
        [ValidateLength(0, 255)]
        [string]$comment,
        [Parameter (Mandatory = $false)]
        [boolean]$visibility,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFMGConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }

        $uri = "firewall/address/$($address.name)"

        $_address = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('name') ) {
            #TODO check if there is no already a object with this name ?
            $_address | add-member -name "name" -membertype NoteProperty -Value $name
            $address.name = $name
        }

        if ( $PSCmdlet.ParameterSetName -ne "default" -and $address.type -ne $PSCmdlet.ParameterSetName ) {
            throw "Address type ($($address.type)) need to be on the same type ($($PSCmdlet.ParameterSetName))"
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            "ipmask" {
                if ( $PsBoundParameters.ContainsKey('ip') -or $PsBoundParameters.ContainsKey('mask') ) {
                    if ( $PsBoundParameters.ContainsKey('ip') ) {
                        $subnet = $ip.ToString()
                    }
                    else {
                        $subnet = ($address.subnet -split ' ')[0]
                    }

                    $subnet += "/"

                    if ( $PsBoundParameters.ContainsKey('mask') ) {
                        $subnet += $mask.ToString()
                    }
                    else {
                        $subnet += ($address.subnet -split ' ')[1]
                    }

                    $_address | add-member -name "subnet" -membertype NoteProperty -Value $subnet
                }
            }
            "iprange" {
                if ( $PsBoundParameters.ContainsKey('startip') ) {
                    $_address | add-member -name "start-ip" -membertype NoteProperty -Value $startip.ToString()
                }

                if ( $PsBoundParameters.ContainsKey('endip') ) {
                    $_address | add-member -name "end-ip" -membertype NoteProperty -Value $endip.ToString()
                }
            }
            "fqdn" {
                if ( $PsBoundParameters.ContainsKey('fqdn') ) {
                    $_address | add-member -name "fqdn" -membertype NoteProperty -Value $fqdn
                }
            }
            default { }
        }

        if ( $PsBoundParameters.ContainsKey('interface') ) {
            #TODO check if the interface (zone ?) is valid
            $_address | add-member -name "associated-interface" -membertype NoteProperty -Value $interface
        }

        if ( $PsBoundParameters.ContainsKey('comment') ) {
            $_address | add-member -name "comment" -membertype NoteProperty -Value $comment
        }

        if ( $PsBoundParameters.ContainsKey('visibility') ) {
            #with 6.4.x, there is no longer visibility parameter
            if ($connection.version -ge "6.4.0") {
                Write-Warning "-visibility parameter is no longer available with FortiOS 6.4.x and after"
            }
            else {
                if ( $visibility ) {
                    $_address | add-member -name "visibility" -membertype NoteProperty -Value "enable"
                }
                else {
                    $_address | add-member -name "visibility" -membertype NoteProperty -Value "disable"
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($address.name, 'Configure Firewall Address')) {
            Invoke-FMGRestMethod -method "set" -type 'pm' -body $_address -uri $uri -connection $connection @invokeParams | out-Null

            Get-FMGFirewallAddress -connection $connection @invokeParams -name $address.name
        }
    }

    End {
    }
}

function Remove-FMGFirewallAddress {

    <#
        .SYNOPSIS
        Remove a Firewall Address

        .DESCRIPTION
        Remove an address object on the Firewall

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Remove-FMGFirewallAddress

        Remove address object $MyFMGAddress

        .EXAMPLE
        $MyFMGAddress = Get-FMGFirewallAddress -name MyFMGAddress
        PS C:\>$MyFMGAddress | Remove-FMGFirewallAddress -confirm:$false

        Remove address object $MyFMGAddress with no confirmation

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateScript( { Confirm-FMGAddress $_ })]
        [psobject]$address,
        [Parameter(Mandatory = $false)]
        [psobject]$connection = $DefaultFMGConnection
    )

    Begin {
    }

    Process {

        $invokeParams = @{ }

        $uri = "firewall/address/$($address.name)"

        if ($PSCmdlet.ShouldProcess($address.name, 'Remove Firewall Address')) {
            $null = Invoke-FMGRestMethod -method "delete" -type 'pm' -uri $uri -connection $connection @invokeParams
        }
    }

    End {
    }
}
