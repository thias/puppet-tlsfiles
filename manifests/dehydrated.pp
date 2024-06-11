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
  String $srcdir,
  Enum['present', 'absent'] $ensure = 'present',
  String $crtpath = '/etc/pki/tls/certs',
  String $keypath = '/etc/pki/tls/private',
  String $crtmode = '0644',
  String $keymode = '0600',
  String $owner   = 'root',
  String $group   = 'root',
  String $pemfile = "${title}.pem",
  String $crtfile = "${title}.crt",
  String $keyfile = "${title}.key",
  String $intfile = "${title}-chain.crt",
  Boolean $intjoin = true,
  Boolean $pem     = false,
) {

  # Look for requested "wildcard.example.com" inside "example.com" dir
  $crt = regsubst($title, 'wildcard.', '')

  $crtdir = "${srcdir}/${crt}"

  # For PEM, we group crt+key+int in a single file
  if $pem {
    # PEM file
    file { "${keypath}/${pemfile}":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => template("${crtdir}/cert.pem","${crtdir}/privkey.pem","${crtdir}/chain.pem")
    }
  } else {
    # Key file
    file { "${keypath}/${keyfile}":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => template("${crtdir}/privkey.pem"),
    }
    # Certificate file (+ Intermediate)
    if $intjoin == true {
      $crtcontent = template("${crtdir}/cert.pem","${crtdir}/chain.pem")
    } else {
      $crtcontent = template("${crtdir}/cert.pem")
    }
    file { "${crtpath}/${crtfile}":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => $crtmode,
      content => $crtcontent,
    }
    # Intermediate, when not joined
    if $intjoin == false {
      file { "${crtpath}/${intfile}":
        ensure  => $ensure,
        owner   => $owner,
        group   => $group,
        mode    => $crtmode,
        content => template("${crtdir}/chain.pem"),
      }
    }
  }
}
