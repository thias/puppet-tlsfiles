# Define: tlsfiles
#
# Manage Private Key Infrastructure (PKI) Transport Layer Security (TLS) files.
#
define tlsfiles (
  $crt,
  $key,
  $intermediate_crt = '',
  $crtpath = '/etc/pki/tls/certs',
  $keypath = '/etc/pki/tls/private',
  $crtmode = '0644',
  $keymode = '0600',
  $owner   = 'root',
  $group   = 'root',
  $intermediate_crt_name = false,
  $join_intermediate_crt = false,
  $want_pem     = false,
) {
  # Use the definition's title the file name
  $cn = $title
  
  # For pem, we group crt+key(+intermediate_crt) in a single file
  if $want_pem {
    $want_pemcontent = $intermediate_crt_name ? {
      false   => $crt+"\n"+$key,
      default => $crt+"\n"+$intermediate_crt+"\n"+$key,
    }
    # want_pem file
    file { "${keypath}/${cn}.want_pem":
      owner   => $owner,
      group   => $group,
      mode    => $keymode,
      content => $want_pemcontent,
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
    $crtcontent = $join_intermediate_crt ? {
      true  => $crt+"\n"+$intermediate_crt,
      false => $crt,
    }
    file { "${crtpath}/${cn}.crt":
      owner   => $owner,
      group   => $group,
      mode    => $crtmode,
      content => $crtcontent,
    }
    # Intermediate, when not joined
    if $intermediate_crt_name != false and $join_intermediate_crt == false {
      file { "${crtpath}/${intermediate_crt_name}.crt":
        owner   => $owner,
        group   => $group,
        mode    => $crtmode,
        content => $intermediate_crt,
      }
    }
  }
}

