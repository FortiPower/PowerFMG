

# PowerFMG

This is a Powershell module for configure a FortiManager (Fortinet) Manager.

With this module (version 0.1.0) you can manage:

- [Address](#address) (Add/Get/Copy/Set/Remove object type ipmask/subnet, FQDN, iprange)

There is some extra feature
- [Invoke API](#invoke-api)
- [ADOM](#ADOM)
- [Filtering](#filtering)
- [Multi Connection](#multiconnection)

More functionality will be added later.

Tested with FortiManager (using 6.x and 7.x)

# Usage

All resource management functions are available with the Powershell verbs GET, ADD, COPY, SET, REMOVE.  
For example, you can manage Address with the following commands:
- `Get-FMGFirewallAddress`
- `Add-FMGFirewallAddress`
- `Copy-FMGFirewallAddress`
- `Set-FMGFirewallAddress`
- `Remove-FMGFirewallAddress`

# Requirements

- Powershell 5 or 6.x/7.x (Core) (If possible get the latest version)
- A Fortinet FortiManager Manager and HTTPS enable with JSON API enable for the user

# Instructions
### Install the module
```powershell
# Automated installation (Powershell 5 or later):
    Install-Module PowerFMG

# Import the module
    Import-Module PowerFMG

# Get commands in the module
    Get-Command -Module PowerFMG

# Get help
    Get-Help Get-FMGFirewallAddress -Full
```

# Examples
### Connecting to the FFortiManager

The first thing to do is to connect to a FortiManager with the command `Connect-FMG` :

```powershell
# Connect to the FortiManager
    Connect-FMG 192.0.2.1

#we get a prompt for credential
```
if you get a warning about `Unable to connect` Look [Issue](#issue)


### Address

You can create a new Address `Add-FMGFirewallAddress`, retrieve its information `Get-FMGFirewallAddress`,
modify its properties `Set-FMGFirewallAddress`, copy/clone its properties `Copy-FMGFirewallAddress`
or delete it `Remove-FMGFirewallAddress`.

```powershell

# Get information about ALL address (using Format Table)
    Get-FMGFirewallAddress | Format-Table

    dynamic_mapping list tagging name                          subnet                             type    associated-interface comment
    --------------- ---- ------- ----                          ------                             ----    -------------------- -------
                                FABRIC_DEVICE                 {0.0.0.0, 0.0.0.0}                 ipmask  {any}                IPv4 addresses of Fabric Devices.
                                FCTEMS_ALL_FORTICLOUD_SERVERS                                    dynamic {any}
                                FIREWALL_AUTH_PORTAL_ADDRESS  {0.0.0.0, 0.0.0.0}                 ipmask  {any}
                                SSLVPN_TUNNEL_ADDR1                                              iprange {sslvpn_tun_intf}
                                all                           {0.0.0.0, 0.0.0.0}                 ipmask  {any}
                                gmail.com                                                        fqdn    {any}
                                login.microsoft.com                                              fqdn    {any}
                                login.microsoftonline.com                                        fqdn    {any}
                                login.windows.net                                                fqdn    {any}
                                metadata-server               {169.254.169.254, 255.255.255.255} ipmask  {any}
                                none                          {0.0.0.0, 255.255.255.255}         ipmask  {any}
                                wildcard.dropbox.com                                             fqdn    {any}
                                wildcard.google.com                                              fqdn    {any}

# Create an address (type ipmask)
    Add-FMGFirewallAddress -Name 'My PowerFMG Network' -ip 192.0.2.1 -mask 255.255.255.0

    dynamic_mapping      :
    list                 :
    tagging              :
    name                 : My PowerFMG Network
    subnet               : {192.0.2.1, 255.255.255.0}
    type                 : ipmask
    associated-interface : {any}
    color                : 0
    uuid                 : 1ce5dcd4-e4ac-51eb-114b-e1fc752f3cf3
    allow-routing        : disable
    sdn-addr-type        : private
    clearpass-spt        : unknown
    obj-type             : ip
    node-ip-only         : disable
    fabric-object        : disable
    macaddr              : {}

# Get information an address (name) and display only some field (using Format-Table)
    Get-FMGFirewallAddress -name "My PowerFMG Network" | Select name, subnet, type, uuid

    name                subnet                     type   uuid
    ----                ------                     ----   ----
    My PowerFMG Network {192.0.2.1, 255.255.255.0} ipmask 1ce5dcd4-e4ac-51eb-114b-e1fc752f3cf3

# Modify an address (name, comment, interface...)
    Get-FMGFirewallAddress -name "My PowerFMG Network" | Set-FMGFirewallAddress -name "MyNetwork" -comment "My comment" -interface port2

    dynamic_mapping      :
    list                 :
    tagging              :
    name                 : MyNetwork
    subnet               : {192.0.2.0, 255.255.255.0}
    type                 : ipmask
    associated-interface : {port2}
    comment              : My comment
    color                : 0
    uuid                 : 4d42661a-e4af-51eb-3720-bb2231d019c0
    allow-routing        : disable
    sdn-addr-type        : private
    clearpass-spt        : unknown
    obj-type             : ip
    node-ip-only         : disable
    fabric-object        : disable
    macaddr              : {}


# Copy/Clone an address
    Get-FMGFirewallAddress -name "MyNetwork" | Copy-FMGFirewallAddress -name "My New Network"

    dynamic_mapping      :
    list                 :
    tagging              :
    name                 : My New Network
    subnet               : {192.0.2.0, 255.255.255.0}
    type                 : ipmask
    associated-interface : {port2}
    comment              : My comment
    color                : 0
    uuid                 : 5f312104-e4af-51eb-de22-614ece107f71
    allow-routing        : disable
    sdn-addr-type        : private
    clearpass-spt        : unknown
    obj-type             : ip
    node-ip-only         : disable
    fabric-object        : disable
    macaddr              : {}

# Remove an address
    Get-FMGFirewallAddress -name "MyNetwork" | Remove-FMGFirewallAddress

    Confirm
    Are you sure you want to perform this action?
    Performing the operation "Remove Firewall Address" on target "MyNetwork".
    [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):Y

#You can also create other address type like fqdn or iprange

# Create an address (type fqdn)
    Add-FMGFirewallAddress -Name FortiPower -fqdn fortipower.github.io

    dynamic_mapping      :
    list                 :
    tagging              :
    name                 : FortiPower
    type                 : fqdn
    fqdn                 : fortipower.github.io
    associated-interface : {any}
    cache-ttl            : 0
    color                : 0
    uuid                 : 8398e176-e4af-51eb-96ee-c11eb689e077
    allow-routing        : disable
    sdn-addr-type        : private
    clearpass-spt        : unknown
    obj-type             : ip
    node-ip-only         : disable
    fabric-object        : disable
    macaddr              : {}

# Create an address (type iprange)
    Add-FMGFirewallAddress -Name MyRange -startip 192.0.2.1 -endip 192.0.2.100

    dynamic_mapping      :
    list                 :
    tagging              :
    name                 : MyRange
    type                 : iprange
    start-ip             : 192.0.2.1
    end-ip               : 192.0.2.100
    associated-interface : {any}
    color                : 0
    uuid                 : 8f11fbc8-e4af-51eb-7ed4-b6f54e534624
    sdn-addr-type        : private
    clearpass-spt        : unknown
    obj-type             : ip
    node-ip-only         : disable
    fabric-object        : disable
    macaddr              : {}

```

### Filtering

For `Invoke-FMGRestMethod`, it is possible to use -filter parameter
You need to use FortiManager API syntax :

```
"filter": [ <source>, <operator>, <target1>, <target2>, ... ]
```

For example to get Firewall Address name equal to My Network, you need to use the following filter array
```powershell
Invoke-FMGRestMethod -uri firewall/address -type pm -filter @("name", "==", "My Network")

[...]
```

and Filter Operators :

|  Operator |  Description
| ---------- | -------------------
| == | Equal to
| != | Not equal to
| < | Less than
| <= | Less than or equal to
| > | Greater than
| >= | Greater than or equal to
| & | Bitwise AND, target can be integer value only, test if (source & target) = 0
| & | Bitwise AND, target can be integer value only, test if (source & target1) = target2
| in | Test if source is one of the values in target
| contain | If source have a list of values, test if it contains target
| like | SQL pattern matching, where target is a string using % (any character) and _ (single character) wildcard
| !like | Not like, inverse of "like" operation
| glob | Case-sensitive pattern matching with target string using UNIX wildcards
| !glob | Not glob, inverse of "glob" operation
| && | Logical AND operator for nested filter with multiple criteria, where source and target must be another filter
| \|\| | Logical OR operator for nested filter with multiple criteria, where source and target must be another filter

For  `Invoke-FMGRestMethod` and `Get-XXX` cmdlet like `Get-FMGFirewallAddress`, it is possible to using some helper filter (`-filter_attribute`, `-filter_type`, `-filter_value`)

```powershell
# Get NetworkDevice named myFMG
    Get-FMGFirewallAddress -name myFMG
...

# Get NetworkDevice contains myFMG
    Get-FMGFirewallAddress -name myFMG -filter_type contains
...

# Get NetworkDevice where subnet equal 192.0.2.0 255.255.255.0
    Get-FMGFirewallAddress -filter_attribute subnet -filter_type equal -filter_value 192.0.2.0 255.255.255.0
...

```
Actually, support only `equal` and `contains` filter type

### Invoke API
for example to get FortiManager System Status Info

```powershell
# get FortiManager System Status using API

    Invoke-FMGRestMethod -method "get" sys/status

    Admin Domain Configuration  : Enabled
    BIOS version                : 04000002
    Branch Point                : 0047
    Build                       : 0047
    Current Time                : Wed Jul 14 16:34:50 CEST 2021
    Daylight Time Saving        : Yes
    FIPS Mode                   : Disabled
    HA Mode                     : Stand Alone
    Hostname                    : PowerFMG
    License Status              : Valid
    Major                       : 7
    Max Number of Admin Domains : 3
    Max Number of Device Groups : 3
    Minor                       : 0
    Offline Mode                : Disabled
    Patch                       : 0
    Platform Full Name          : FortiManager-VM64
    Platform Type               : FMG-VM64
    Release Version Information :  (GA)
    Serial Number               : FMG-VMTM21000000
    TZ                          : Europe/Brussels
    Time Zone                   : (GMT+1:00) Brussels, Copenhagen, Madrid, Paris.
    Version                     : v7.0.0-build0047 210422 (GA)
    x86-64 Applications         : Yes
[...]
```
You can look `FortiManager - JSON API (Full Reference)` available on [Fortinet Developer Network (FNDN)](https://fndn.fortinet.net/)

You don't need to specify the ADOM when you query Configuration Database (pm), you can use type parameter to automally set the adom

For example to query the firewall address of pester adom (configured when connect)
```powershell
    Invoke-FMGRestMethod -type pm "firewall/address" -Verbose
    VERBOSE: {
    "id": 1,
    "method": "get",
    "session": "bxQu/WY9cgBFgtZcBMiUNaQydn2IBrPwSzc+e75d8JOmmjy9V9Dd/p6RuTCo2WaEA+ibRIxARrHcthInXGvQ9w==",
    "params": [
        {
        "url": "pm/config/adom/pester/obj/firewall/address"
        }
    ],
    "verbose": 1
    }
    [...]
```

### ADOM

it is possible set ADOM when connect to FortiManager (by default it is on root adom)

For connect on the pester vdom 
```powershell
    Connect-FMG 192.0.2.1 -adom pester
[...]
```
<!--You can also change default adom using
```powershell
    Set-FMGConnection -adom vdomY
[...]
```
-->


### MultiConnection

it is possible to connect on same times to multi FortiManager (or same Manager with different adom)
You need to use -connection parameter to cmdlet

For example to get Firewall Address of 2 FortiManager

```powershell
# Connect to first FortiManager
    $fmg1 = Connect-FMG 192.0.2.1 -SkipCertificateCheck -DefaultConnection:$false

#DefaultConnection set to false is not mandatory but only don't set the connection info on global variable

# Connect to second FortiManager
    $fmg2 = Connect-FMG 192.0.2.2 -SkipCertificateCheck -DefaultConnection:$false

# Get Firewall Address for first FortiManager
    Get-FMGFirewallAddress -connection $fmg1 | Format-Table

    dynamic_mapping list tagging name                          subnet                             type    associated-interface comment
    --------------- ---- ------- ----                          ------                             ----    -------------------- -------
                                FortiPower                                                       fqdn    {any}
                                My New Network                {192.0.2.0, 255.255.255.0}         ipmask  {port2}              My comment
                                MyRange                                                          iprange {any}
....

# Get Firewall Address for second FortiManager
    Get-FMGFirewallAddress -connection $fmg2 | Format-Table

    dynamic_mapping list tagging name                          subnet                             type    associated-interface comment
    --------------- ---- ------- ----                          ------                             ----    -------------------- -------
                                FABRIC_DEVICE                 {0.0.0.0, 0.0.0.0}                 ipmask  {any}                IPv4 addresses of Fabric Devices.
                                FCTEMS_ALL_FORTICLOUD_SERVERS                                    dynamic {any}
                                FIREWALL_AUTH_PORTAL_ADDRESS  {0.0.0.0, 0.0.0.0}                 ipmask  {any}
                                SSLVPN_TUNNEL_ADDR1                                              iprange {sslvpn_tun_intf}
                                all                           {0.0.0.0, 0.0.0.0}                 ipmask  {any}
...

#Each cmdlet can use -connection parameter

```

### Disconnecting

```powershell
# Disconnect from the FortiManager
    Disconnect-FMG
```

# Issue

## Unable to connect (certificate)

if you use `Connect-FMG` and get `Unable to Connect (certificate)`

The issue coming from use Self-Signed or Expired Certificate for FortiManager  
Try to connect using `Connect-FMG -SkipCertificateCheck`

# How to contribute

Contribution and feature requests are more than welcome. Please use the following methods:

  * For bugs and [issues](https://github.com/FortiPower/PowerFMG/issues), please use the [issues](https://github.com/FortiPower/PowerFMG/issues) register with details of the problem.
  * For Feature Requests, please use the [issues](https://github.com/FortiPower/PowerFMG/issues) register with details of what's required.
  * For code contribution (bug fixes, or feature request), please request fork PowerFMG, create a feature/fix branch, add tests if needed then submit a pull request.

# Contact

Currently, [@alagoutte](#author) started this project and will keep maintaining it. Reach out to me via [Twitter](#author), Email (see top of file) or the [issues](https://github.com/FortiPower/PowerFMG/issues) Page here on GitHub. If you want to contribute, also get in touch with me.

# List of available command
```powershell
Add-FMGFirewallAddress
Confirm-FMGAddress
Connect-FMG
Copy-FMGFirewallAddress
Disconnect-FMG
Get-FMGFirewallAddress
Invoke-FMGRestMethod
Remove-FMGFirewallAddress
Set-FMGCipherSSL
Set-FMGFirewallAddress
Set-FMGUntrustedSSL
Show-FMGException
```

# Author

**Alexis La Goutte**
- <https://github.com/alagoutte>
- <https://twitter.com/alagoutte>

# Special Thanks

- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- Erwan Quelin for help about Powershell

# License

Copyright 2021 Alexis La Goutte and the community.
