# puppet-tlsfiles

## Overview

This module is used to manage Private Key Infrastructure (PKI) Transport Layer
Security (TLS) files. Typically these are Secure Socket Layer (SSL) X.509
private keys and certificates.

The module supports installing intermediate certificates as well as optionally
joining keys and certificates into single files.

* `tlsfiles` : Manage key and certificate

## Parameters

* `$crtpath = '/etc/pki/tls/certs'`
* `$keypath = '/etc/pki/tls/private'`
* `$crtmode = '0644'`
* `$keymode = '0600'`
* `$owner   = 'root'`
* `$group   = 'root'`
* `$intcert = false`
* `$intjoin = false`
* `$pem     = false`
* `$srcdir  = 'tlsfiles'`

## Examples

To install keys and certificates present under :

* `mymodulename/templates/tlsfiles/crt/www.example.com.crt`
* `mymodulename/templates/tlsfiles/key/www.example.com.key`

In `site.pp` to centralize all of your files :

```puppet
Tlsfile { srcdir => 'mymodulename/tlsfiles' }
```

Install both files to the default `/etc/pki/tls/` locations :

```puppet
tlsfile { 'www.example.com': }
```

Install a PEM file containing both to a custom location :

```puppet
tlsfile { 'www.example.com':
  keypath => '/etc/foo/www.example.com.pem',
  pem     => true,
}
```

