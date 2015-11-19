# puppet-tlsfiles

## Overview

This module is used to manage Private Key Infrastructure (PKI) Transport Layer
Security (TLS) files. Typically these are Secure Socket Layer (SSL) X.509
private keys and certificates.

The module supports installing intermediate certificates as well as optionally
joining keys and certificates into single files.

The module supports the use of hiera to feed in certificate files dynamically and securely if using a secure hiera backend such as hiera-eyaml.

* `tlsfiles` : Manage key and certificate

## Parameters

* `$crt`
* `$key`
* `$intermediate_crt  = ''`
* `$crtpath = '/etc/pki/tls/certs'`
* `$keypath = '/etc/pki/tls/private'`
* `$crtmode = '0644'`
* `$keymode = '0600'`
* `$owner   = 'root'`
* `$group   = 'root'`
* `$intermediate_crt_name = false`
* `$join_intermediate_crt = false`
* `$want_pem     = false`

## Examples

In your hiera yaml datafile:
```
tlsfiles:
    "%{trusted.certname}":
        crt: ENC[PKCS7,MII...snip...]
        key: ENC[PKCS7,MII...snip...TI=]
        intermediate_crt: ENC[PKCS7,MII...snip...98M]
        intcert: "DigiCert"
```
And in your puppet class:
```
class profile::apache {
    include ::apache
  
    $tlsfiles = hiera_hash('tlsfiles')
    create_resources('tlsfiles',$tlsfiles)
}
```
