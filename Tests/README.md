# PowerFMG Tests

## Pre-Requisites

The tests don't be to be run on PRODUCTION FortiManager ! there is no warning about change on the Firewall.
It need to be use only for TESTS !

    A FortiManager (VM) with release >= 6.0.x (Tested with 6.x and 7.x)
    a user and password for admin account (with API JSON enable)

These are the required modules for the tests

    Pester

## Executing Tests

Assuming you have git cloned the PowerFMG repository. Go on tests folder and copy credentials.example.ps1 to credentials.ps1 and edit to set information about your FortiManager (ipaddress, login, password, adom)

Go after on integration folder and launch all tests via

```powershell
Invoke-Pester *
```

It is possible to custom some settings when launch test (like Firewall Address Object used), you need to uncommented following line on credentials.ps1

```powershell
$pester_address1 = My_address1

...
```

## Executing Individual Tests

Tests are broken up according to functional area. If you are working on Connection functionality for instance, its possible to just run Connection related tests.

Example:

```powershell
Invoke-Pester Connection.Tests.ps1
```

if you only launch a sub test (Describe on pester file), you can use for example to 'Connect to a FortiManager' part

```powershell
Invoke-Pester Connection.Tests.ps1 -testName "Connect to a FortiManager"
```

## Known Issues

No known issues (for the moment...)