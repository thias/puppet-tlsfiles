# puppet-tlsfiles

## Overview

This module is used to manage Private Key Infrastructure (PKI) Transport Layer
Security (TLS) files. Typically these are Secure Socket Layer (SSL) X.509
private keys and certificates.

The module supports installing intermediate certificates as well as optionally
joining keys and certificates into single files.

* `tlsfiles` : Manage key and certificate

## Examples

To install keys and certificates present under
`mymodulename/templates/tlsfiles/{key,crt}/` :

    # In site.pp
    Tlsfile { srcdir => 'mymodulename/tlsfiles' }
    # For a given node
    tlsfile { [ 'www.example.com', 'admin.example.com' ]: }

