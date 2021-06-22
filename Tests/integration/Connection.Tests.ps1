#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Connect to a FortiManager (using HTTPS)" {
    It "Connect to a FortiManager (using HTTPS and -SkipCertificateCheck) and check global variable" {
        Connect-FMG $ipaddress -Username $login -password $mysecpassword -adom $adom -SkipCertificateCheck -port $port
        $DefaultFMGConnection | Should -Not -BeNullOrEmpty
        $DefaultFMGConnection.server | Should -Be $ipaddress
        $DefaultFMGConnection.invokeParams | Should -Not -BeNullOrEmpty
        $DefaultFMGConnection.port | Should -Be $port
        $DefaultFMGConnection.adom | Should -Be $adom
        $DefaultFMGConnection.session | Should -Not -BeNullOrEmpty
        #$DefaultFMGConnection.headers | Should -Not -BeNullOrEmpty
        $DefaultFMGConnection.version | Should -Not -BeNullOrEmpty
    }
    It "Disconnect to a FortiManager (using HTTPS) and check global variable" {
        Disconnect-FMG -confirm:$false
        $DefaultFMGConnection | Should -Be $null
    }
    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Connect to a FortiManager (using HTTPS) and check global variable" -Skip:("Desktop" -eq $PSEdition) {
        { Connect-FMG $ipaddress -Username $login -password $mysecpassword } | Should -throw "Unable to connect (certificate)"
    }
}


Describe "Connect to a FortiManager (using multi connection)" {
    It "Connect to a FortiManager (using HTTPS and store on fmg variable)" {
        $script:fmg = Connect-FMG $ipaddress -Username $login -password $mysecpassword -adom $adom -SkipCertificate -DefaultConnection:$false -port $port
        $DefaultFMGConnection | Should -BeNullOrEmpty
        $fmg.session | Should -Not -BeNullOrEmpty
        $fmg.server | Should -Be $ipaddress
        $fmg.invokeParams | Should -Not -BeNullOrEmpty
        $fmg.port | Should -Be $port
        $fmg.adom | Should -Be $adom
        $fmg.session | Should -Not -BeNullOrEmpty
        #$fmg.headers | Should -Not -BeNullOrEmpty
        $fmg.version | Should -Not -BeNullOrEmpty
    }

    It "Throw when try to use Invoke-FMGRestMethod and not connected" {
        { Invoke-FMGRestMethod -uri "api/v2/cmdb/firewall/address" } | Should -Throw "Not Connected. Connect to the FortiManager with Connect-FMG"
    }

    Context "Use Multi connection for call some (Get) cmdlet (Vlan, System...)" {
        #It "Use Multi connection for call Get Firewall Address" {
        #    { Get-FMGFirewallAddress -connection $fmg } | Should -Not -Throw
        #}
    }

    It "Disconnect to a FortiManager (Multi connection)" {
        Disconnect-FMG -connection $fmg -confirm:$false
        $DefaultFMGConnection | Should -Be $null
    }

    AfterAll {
        #Remove script scope variable
        Remove-Variable -name fmg -scope script
    }

}