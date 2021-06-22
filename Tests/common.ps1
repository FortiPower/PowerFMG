#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.1.0" }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
Param()
# default settings for test...
$script:pester_address1 = "pester_address1"
$script:pester_address2 = "pester_address2"
$script:pester_address3 = "pester_address3"
$script:pester_address4 = "pester_address4"

. ../credential.ps1
#TODO: Add check if no ipaddress/login/password info...

if ($null -eq $port) {
    $script:port = 443
}

$script:mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force

$script:invokeParams = @{
    Server               = $ipaddress;
    username             = $login;
    password             = $mysecpassword;
    port                 = $port;
    SkipCertificateCheck = $true;
    adom                 = $adom;
}

#Make a connection for check info and store version (used for some test...)
$FMG = Connect-FMG @invokeParams
$FMG_version = $FMG.version
Disconnect-FMG -confirm:$false