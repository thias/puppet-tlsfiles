# Define: tlsfiles::dehydrated
#
# Manage Private Key Infrastructure (PKI) Transport Layer Security (TLS) files.
#
# Sample Usage :
#  # Files would be inside mymodulename/templates/certs/
#  # With certs/ having a dehydrated "certs" content of <cert>/*.pem files
#  # (can be a symlink to the dehydrated "certs" directory)
#  tlsfile::dehydrated { 'www.example.com':
#    srcdir => 'mymodulename/certs',
#  }
#
# Worth noting (mostly differences with main definition):
# * We always have an intermediate certificate.
# * We join intermediate by default
# * We don't need the fullchain, we use cert+chain instead (save on content)
#
define tlsfiles::dehydrated (
  $srcdir,
  $ensure  = 'present',
  $crtpath = '/etc/pki/tls/certs',
  $keypath = '/etc/pki/tls/private',
  $crtmode = '0644',
  $keymode = '0600',
  $owner   = 'root',
  $group   = 'root',
  $intcert = "${title}-chain",
  $intjoin = true,
  $pem     = false,
) {

  # Look for "wildcard.example.com" inside "example.com"
  $crt = regsubst($title, 'wildcard.', '')

  $crtdir = "${srcdir}/${crt}"

  # For PEM, we group crt+key(+intcert) in a single file
  if $pem {
    # PEM file
    file { "${keypath}/${title}.pem":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => template("${crtdir}/cert.pem","${crtdir}/privkey.pem","${crtdir}/chain.pem")
    }
  } else {
    # Key file
    file { "${keypath}/${title}.key":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => template("${crtdir}/privkey.pem"),
    }
    # Crt files (+ Intermediate)
    if $intjoin == true {
      $crtcontent = template("${crtdir}/cert.pem","${crtdir}/chain.pem")
    } else {
      $crtcontent = template("${crtdir}/cert.pem")
    }
    file { "${crtpath}/${title}.crt":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $crtmode,
      content => $crtcontent,
    }
    # Intermediate, when not joined
    if $intjoin == false {
      file { "${crtpath}/${intcert}.crt":
        ensure  => $ensure,
        owner   => $owner,
        group   => $group,
        mode    => $crtmode,
        content => template("${crtdir}/chain.pem"),
      }
    }
  }
}
