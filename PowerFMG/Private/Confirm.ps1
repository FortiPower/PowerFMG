
#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
Function Confirm-FMGAddress {

    Param (
        [Parameter (Mandatory = $true)]
        [object]$argument
    )

    #Check if it looks like an Address element

    if ( -not ( $argument | get-member -name name -Membertype Properties)) {
        throw "Element specified does not contain a name property."
    }
    if ( -not ( $argument | get-member -name uuid -Membertype Properties)) {
        throw "Element specified does not contain an uuid property."
    }
    if ( -not ( $argument | get-member -name type -Membertype Properties)) {
        throw "Element specified does not contain a type property."
    }
    #if ( -not ( $argument | get-member -name country -Membertype Properties)) {
    #    throw "Element specified does not contain a country property."
    #}

    $true

}