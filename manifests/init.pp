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
  $intcert = undef,
  $intjoin = false,
  $pem     = false,
  $srcdir  = 'tlsfiles',
  $crtdir  = 'crt',
  $keydir  = 'key',
  $crtname = "${title}.crt",
  $keyname = "${title}.key",
) {
  # For PEM, we group crt+key(+intcert) in a single file
  if $pem {
    $pemcontent = $intcert ? {
      undef   => template("${srcdir}/${crtdir}/${crtname}","${srcdir}/${keydir}/${keyname}"),
      default => template("${srcdir}/${crtdir}/${crtname}","${srcdir}/${keydir}/${keyname}","${srcdir}/${crtdir}/${intcert}.crt"),
    }
    # PEM file
    file { "${keypath}/${title}.pem":
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => $pemcontent,
    }
  } else {
    # Key file
    file { "${keypath}/${title}.key":
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => template("${srcdir}/${keydir}/${keyname}"),
    }
    # Crt files (+ Intermediate)
    if $intcert and $intjoin == true {
      $crtcontent = template("${srcdir}/${crtdir}/${crtname}","${srcdir}/${crtdir}/${intcert}.crt")
    } else {
      $crtcontent = template("${srcdir}/${crtdir}/${crtname}")
    }
    file { "${crtpath}/${title}.crt":
      owner   => $owner,
      group   => $group,
      mode    => $crtmode,
      content => $crtcontent,
    }
    # Intermediate, when not joined
    if $intcert and $intjoin == false {
      file { "${crtpath}/${intcert}.crt":
        owner   => $owner,
        group   => $group,
        mode    => $crtmode,
        content => template("${srcdir}/${crtdir}/${intcert}.crt"),
      }
    }
  }
}

