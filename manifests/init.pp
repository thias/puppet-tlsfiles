# Define: tlsfiles
#
# Manage Private Key Infrastructure (PKI) Transport Layer Security (TLS) files.
#
# Sample Usage :
#  # Files would be inside mymodulename/templates/tlsfiles/
#  tlsfile { 'www.example.com':
#    srcdir => 'mymodulename/tlsfiles',
#  }
#
define tlsfiles (
  $crtpath = '/etc/pki/tls/certs',
  $keypath = '/etc/pki/tls/private',
  $crtmode = '0644',
  $keymode = '0600',
  $owner   = 'root',
  $group   = 'root',
  $intcert = false,
  $intjoin = false,
  $pem     = false,
  $srcdir  = 'tlsfiles',
  $crt     = '',
  $key     = '',
  $intermediate_crt = '',
) {
  # Use the definition's title as the CN which is also the file name
  $cn = $title
  # For PEM, we group crt+key(+intcert) in a single file
  if $pem {
    $pemcontent = $intcert ? {
      false   => template($crt,$key),
      default => template($crt,$intermediate_crt,$key),
    }
    # PEM file
    file { "${keypath}/${cn}.pem":
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => $pemcontent,
    }
  } else {
    # Key file
    file { "${keypath}/${cn}.key":
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => $key,
    }
    # Crt files (+ Intermediate)
    $crtcontent = $intjoin ? {
      true  => template($crt,$intermediate_crt),
      false => template($crt),
    }
    file { "${crtpath}/${cn}.crt":
      owner   => $owner,
      group   => $group,
      mode    => $crtmode,
      content => $crtcontent,
    }
    # Intermediate, when not joined
    if $intcert != false and $intjoin == false {
      file { "${crtpath}/${intcert}.crt":
        owner   => $owner,
        group   => $group,
        mode    => $crtmode,
        content => template($intermediate_crt),
      }
    }
  }
}

