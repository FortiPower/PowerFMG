#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

#include common configuration
. ../common.ps1

BeforeAll {
    Connect-FMG @invokeParams
}

Describe "Get Firewall Address" {

    BeforeAll {
        $addr = Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0
        $script:uuid = $addr.uuid
        Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io
        Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100
    }

    It "Get Address Does not throw an error" {
        {
            Get-FMGFirewallAddress
        } | Should -Not -Throw
    }

    It "Get ALL Address" {
        $address = Get-FMGFirewallAddress
        $address.count | Should -Not -Be $NULL
    }

    It "Get Address ($pester_address1)" {
        $address = Get-FMGFirewallAddress -name $pester_address1
        $address.name | Should -Be $pester_address1
    }

    It "Get Address ($pester_address1) and confirm (via Confirm-FMGAddress)" {
        $address = Get-FMGFirewallAddress -name $pester_address1
        Confirm-FMGAddress ($address) | Should -Be $true
    }

    Context "Search" {

        It "Search Address by name ($pester_address1)" {
            $address = Get-FMGFirewallAddress -name $pester_address1
            @($address).count | Should -be 1
            $address.name | Should -Be $pester_address1
        }

        It "Search Address by uuid ($script:uuid)" {
            $address = Get-FMGFirewallAddress -uuid $script:uuid
            @($address).count | Should -be 1
            $address.name | Should -Be $pester_address1
        }

    }

    AfterAll {
        Get-FMGFirewallAddress -name $pester_address1 | Remove-FMGFirewallAddress -confirm:$false
        Get-FMGFirewallAddress -name $pester_address2 | Remove-FMGFirewallAddress -confirm:$false
        Get-FMGFirewallAddress -name $pester_address3 | Remove-FMGFirewallAddress -confirm:$false
    }

}

Describe "Add Firewall Address" {

    Context "ipmask" {

        AfterEach {
            Get-FMGFirewallAddress -name $pester_address1 | Remove-FMGFirewallAddress -confirm:$false
        }

        It "Add Address $pester_address1 (type ipmask)" {
            Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            #$address.'start-ip' | Should -Be "192.0.2.0"
            #$address.'end-ip' | Should -Be "255.255.255.0"
            $address.subnet | Should -Be @("192.0.2.0", "255.255.255.0")
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address1 (type ipmask and interface)" {
            Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0 -interface port2
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            #$address.'start-ip' | Should -Be "192.0.2.0"
            #$address.'end-ip' | Should -Be "255.255.255.0"
            $address.subnet | Should -Be @("192.0.2.0", "255.255.255.0")
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address1 (type ipmask and comment)" {
            Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0 -comment "Add via PowerFMG"
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            #$address.'start-ip' | Should -Be "192.0.2.0"
            #$address.'end-ip' | Should -Be "255.255.255.0"
            $address.subnet | Should -Be @("192.0.2.0", "255.255.255.0")
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -Be "Add via PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address1 (type ipmask and visiblity disable)" {
            Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0 -visibility:$false
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            #$address.'start-ip' | Should -Be "192.0.2.0"
            #$address.'end-ip' | Should -Be "255.255.255.0"
            $address.subnet | Should -Be @("192.0.2.0", "255.255.255.0")
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        It "Try to Add Address $pester_address1 (but there is already a object with same name)" {
            #Add first address
            Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0
            #Add Second address with same name
            { Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0 } | Should -Throw "Already an address object using the same name"
        }

    }

    Context "iprange" {

        AfterEach {
            Get-FMGFirewallAddress -name $pester_address3 | Remove-FMGFirewallAddress -confirm:$false
        }

        It "Add Address $pester_address3 (type iprange)" {
            Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.1"
            $address.'end-ip' | Should -Be "192.0.2.100"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address3 (type iprange and interface)" {
            Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100 -interface port2
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.1"
            $address.'end-ip' | Should -Be "192.0.2.100"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address3 (type iprange and comment)" {
            Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100 -comment "Add via PowerFMG"
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.1"
            $address.'end-ip' | Should -Be "192.0.2.100"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -Be "Add via PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address3 (type iprange and visiblity disable)" {
            Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100 -visibility:$false
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.1"
            $address.'end-ip' | Should -Be "192.0.2.100"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        It "Try to Add Address $pester_address3 (but there is already a object with same name)" {
            #Add first address
            Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100
            #Add Second address with same name
            { Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100 } | Should -Throw "Already an address object using the same name"
        }

    }

    Context "fqdn" {

        AfterEach {
            Get-FMGFirewallAddress -name $pester_address2 | Remove-FMGFirewallAddress -confirm:$false
        }

        It "Add Address $pester_address2 (type fqdn)" {
            Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.subnet | Should -BeNullOrEmpty
            $address.fqdn | Should -be "fortipower.github.io"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address2 (type fqdn and interface)" {
            Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io -interface port2
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.subnet | Should -BeNullOrEmpty
            $address.fqdn | Should -be "fortipower.github.io"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address2 (type fqdn and comment)" {
            Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io -comment "Add via PowerFMG"
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.subnet | Should -BeNullOrEmpty
            $address.fqdn | Should -be "fortipower.github.io"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -Be "Add via PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Add Address $pester_address2 (type fqdn and visiblity disable)" {
            Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io -visibility:$false
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.subnet | Should -BeNullOrEmpty
            $address.fqdn | Should -be "fortipower.github.io"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

    }

}

Describe "Configure Firewall Address" {

    Context "ipmask" {

        BeforeAll {
            $address = Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0
            $script:uuid = $address.uuid
        }

        It "Change IP Address" {
            Get-FMGFirewallAddress -name $pester_address1 | Set-FMGFirewallAddress -ip 192.0.3.0
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            #$address.'start-ip' | Should -Be "192.0.3.0"
            #$address.'end-ip' | Should -Be "255.255.255.0"
            $address.subnet | Should -Be @("192.0.3.0", "255.255.255.0")
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change IP Mask" {
            Get-FMGFirewallAddress -name $pester_address1 | Set-FMGFirewallAddress -mask 255.255.255.128
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            # $address.'start-ip' | Should -Be "192.0.3.0"
            # $address.'end-ip' | Should -Be "255.255.255.128"
            $address.subnet | Should -Be @("192.0.3.0", "255.255.255.128")
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change (Associated) Interface" {
            Get-FMGFirewallAddress -name $pester_address1 | Set-FMGFirewallAddress -interface port2
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            # $address.'start-ip' | Should -Be "192.0.3.0"
            # $address.'end-ip' | Should -Be "255.255.255.128"
            $address.subnet | Should -Be @("192.0.3.0", "255.255.255.128")
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change comment" {
            Get-FMGFirewallAddress -name $pester_address1 | Set-FMGFirewallAddress -comment "Modified by PowerFMG"
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            # $address.'start-ip' | Should -Be "192.0.3.0"
            # $address.'end-ip' | Should -Be "255.255.255.128"
            $address.subnet | Should -Be @("192.0.3.0", "255.255.255.128")
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change visiblity" {
            Get-FMGFirewallAddress -name $pester_address1 | Set-FMGFirewallAddress -visibility:$false
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address.name | Should -Be $pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            # $address.'start-ip' | Should -Be "192.0.3.0"
            # $address.'end-ip' | Should -Be "255.255.255.128"
            $address.subnet | Should -Be @("192.0.3.0", "255.255.255.128")
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        It "Try to Configure Address $pester_address1 (but it is wrong type...)" {
            { Get-FMGFirewallAddress -name $pester_address1 | Set-FMGFirewallAddress -fqdn "fortipower.github.io" } | Should -Throw "Address type (ipmask) need to be on the same type (fqdn)"
        }

        It "Change Name" {
            Get-FMGFirewallAddress -name $pester_address1 | Set-FMGFirewallAddress -name "pester_address_change"
            $address = Get-FMGFirewallAddress -name "pester_address_change"
            $address.name | Should -Be "pester_address_change"
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            # $address.'start-ip' | Should -Be "192.0.3.0"
            # $address.'end-ip' | Should -Be "255.255.255.128"
            $address.subnet | Should -Be @("192.0.3.0", "255.255.255.128")
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        AfterAll {
            Get-FMGFirewallAddress -name "pester_address_change" | Remove-FMGFirewallAddress -confirm:$false
        }

    }

    Context "iprange" {

        BeforeAll {
            $address = Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100
            $script:uuid = $address.uuid
        }

        It "Change Start IP" {
            Get-FMGFirewallAddress -name $pester_address3 | Set-FMGFirewallAddress -startip 192.0.2.99
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.99"
            $address.'end-ip' | Should -Be "192.0.2.100"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change End IP" {
            Get-FMGFirewallAddress -name $pester_address3 | Set-FMGFirewallAddress -endip 192.0.2.199
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.99"
            $address.'end-ip' | Should -Be "192.0.2.199"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change (Associated) Interface" {
            Get-FMGFirewallAddress -name $pester_address3 | Set-FMGFirewallAddress -interface port2
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.99"
            $address.'end-ip' | Should -Be "192.0.2.199"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change comment" {
            Get-FMGFirewallAddress -name $pester_address3 | Set-FMGFirewallAddress -comment "Modified by PowerFMG"
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.99"
            $address.'end-ip' | Should -Be "192.0.2.199"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change visiblity" {
            Get-FMGFirewallAddress -name $pester_address3 | Set-FMGFirewallAddress -visibility:$false
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address.name | Should -Be $pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.99"
            $address.'end-ip' | Should -Be "192.0.2.199"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        It "Try to Configure Address $pester_address3 (but it is wrong type...)" {
            { Get-FMGFirewallAddress -name $pester_address3 | Set-FMGFirewallAddress -fqdn "fortipower.github.io" } | Should -Throw "Address type (iprange) need to be on the same type (fqdn)"
        }

        It "Change Name" {
            Get-FMGFirewallAddress -name $pester_address3 | Set-FMGFirewallAddress -name "pester_address_change"
            $address = Get-FMGFirewallAddress -name "pester_address_change"
            $address.name | Should -Be "pester_address_change"
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.99"
            $address.'end-ip' | Should -Be "192.0.2.199"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        AfterAll {
            Get-FMGFirewallAddress -name "pester_address_change" | Remove-FMGFirewallAddress -confirm:$false
        }

    }

    Context "fqdn" {

        BeforeAll {
            $address = Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io
            $script:uuid = $address.uuid
        }

        It "Change fqdn" {
            Get-FMGFirewallAddress -name $pester_address2 | Set-FMGFirewallAddress -fqdn fortipower.github.com
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.fqdn | Should -Be "fortipower.github.com"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change (Associated) Interface" {
            Get-FMGFirewallAddress -name $pester_address2 | Set-FMGFirewallAddress -interface port2
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.fqdn | Should -Be "fortipower.github.com"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change comment" {
            Get-FMGFirewallAddress -name $pester_address2 | Set-FMGFirewallAddress -comment "Modified by PowerFMG"
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.fqdn | Should -Be "fortipower.github.com"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        It "Change visiblity" {
            Get-FMGFirewallAddress -name $pester_address2 | Set-FMGFirewallAddress -visibility:$false
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address.name | Should -Be $pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.fqdn | Should -Be "fortipower.github.com"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        It "Try to Configure Address $pester_address2 (but it is wrong type...)" {
            { Get-FMGFirewallAddress -name $pester_address2 | Set-FMGFirewallAddress -ip 192.0.2.0 -mask 255.255.255.0 } | Should -Throw "Address type (fqdn) need to be on the same type (ipmask)"
        }

        It "Change Name" {
            Get-FMGFirewallAddress -name $pester_address2 | Set-FMGFirewallAddress -name "pester_address_change"
            $address = Get-FMGFirewallAddress -name "pester_address_change"
            $address.name | Should -Be "pester_address_change"
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.fqdn | Should -Be "fortipower.github.com"
            $address.'associated-interface' | Should -Be "port2"
            $address.comment | Should -Be "Modified by PowerFMG"
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be "disable"
            }
        }

        AfterAll {
            Get-FMGFirewallAddress -name "pester_address_change" | Remove-FMGFirewallAddress -confirm:$false
        }

    }

}

Describe "Copy Firewall Address" {

    Context "ipmask" {

        BeforeAll {
            Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0
        }

        It "Copy Firewall Address ($pester_address1 => copy_pester_address1)" {
            Get-FMGFirewallAddress -name $pester_address1 | Copy-FMGFirewallAddress -name copy_pester_address1
            $address = Get-FMGFirewallAddress -name copy_pester_address1
            $address.name | Should -Be copy_pester_address1
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "ipmask"
            # $address.'start-ip' | Should -Be "192.0.2.0"
            # $address.'end-ip' | Should -Be "255.255.255.0"
            $address.subnet | Should -Be @("192.0.2.0", "255.255.255.0")
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        AfterAll {
            #Remove copy_pester_address1
            Get-FMGFirewallAddress -name copy_pester_address1 | Remove-FMGFirewallAddress -confirm:$false
            #Remove $pester_address1
            Get-FMGFirewallAddress -name $pester_address1 | Remove-FMGFirewallAddress -confirm:$false
        }

    }

    Context "iprange" {

        BeforeAll {
            Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100
        }

        It "Copy Firewall Address ($pester_address3 => copy_pester_address3)" {
            Get-FMGFirewallAddress -name $pester_address3 | Copy-FMGFirewallAddress -name copy_pester_address3
            $address = Get-FMGFirewallAddress -name copy_pester_address3
            $address.name | Should -Be copy_pester_address3
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "iprange"
            $address.'start-ip' | Should -Be "192.0.2.1"
            $address.'end-ip' | Should -Be "192.0.2.100"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        AfterAll {
            #Remove copy_pester_address3
            Get-FMGFirewallAddress -name copy_pester_address3 | Remove-FMGFirewallAddress -confirm:$false
            #Remove $pester_address3
            Get-FMGFirewallAddress -name $pester_address3 | Remove-FMGFirewallAddress -confirm:$false
        }

    }

    Context "fqdn" {

        BeforeAll {
            Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io
        }

        It "Copy Firewall Address ($pester_address2 => copy_pester_address2)" {
            Get-FMGFirewallAddress -name $pester_address2 | Copy-FMGFirewallAddress -name copy_pester_address2
            $address = Get-FMGFirewallAddress -name copy_pester_address2
            $address.name | Should -Be copy_pester_address2
            $address.uuid | Should -Not -BeNullOrEmpty
            $address.type | Should -Be "fqdn"
            $address.subnet | Should -BeNullOrEmpty
            $address.fqdn | Should -be "fortipower.github.io"
            $address.'associated-interface' | Should -Be "any"
            $address.comment | Should -BeNullOrEmpty
            if ($DefaultFMGConnection.version -lt "6.4.0") {
                $address.visibility | Should -Be $true
            }
        }

        AfterAll {
            #Remove copy_pester_address2
            Get-FMGFirewallAddress -name copy_pester_address2 | Remove-FMGFirewallAddress -confirm:$false
            #Remove $pester_address2
            Get-FMGFirewallAddress -name $pester_address2 | Remove-FMGFirewallAddress -confirm:$false
        }

    }
}

Describe "Remove Firewall Address" {

    Context "ipmask" {

        BeforeEach {
            Add-FMGFirewallAddress -Name $pester_address1 -ip 192.0.2.0 -mask 255.255.255.0
        }

        It "Remove Address $pester_address1 by pipeline" {
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address | Remove-FMGFirewallAddress -confirm:$false
            $address = Get-FMGFirewallAddress -name $pester_address1
            $address | Should -Be $NULL
        }

    }

    Context "iprange" {

        BeforeEach {
            Add-FMGFirewallAddress -Name $pester_address3 -startip 192.0.2.1 -endip 192.0.2.100
        }

        It "Remove Address $pester_address3 by pipeline" {
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address | Remove-FMGFirewallAddress -confirm:$false
            $address = Get-FMGFirewallAddress -name $pester_address3
            $address | Should -Be $NULL
        }

    }

    Context "fqdn" {

        BeforeEach {
            Add-FMGFirewallAddress -Name $pester_address2 -fqdn fortipower.github.io
        }

        It "Remove Address $pester_address2 by pipeline" {
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address | Remove-FMGFirewallAddress -confirm:$false
            $address = Get-FMGFirewallAddress -name $pester_address2
            $address | Should -Be $NULL
        }

    }

}

AfterAll {
    Disconnect-FMG -confirm:$false
}