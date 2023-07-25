# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   util::pkcs12_to_pem { 'namevar': }
#
# @param pkcs12_azure_cert
#   The certificate to pull from azure key vault
#
# @param pkcs12_path
#   path to write pkcs12 cert to
#
define util::pkcs12_to_pem (
  String[1] $pkcs12_azure_cert,
  Stdlib::Absolutepath $pkcs12_path,
  Stdlib::Absolutepath $pem_key_path,
  Stdlib::Absolutepath $pem_cert_path,
  String[1] $pem_key_owner,
  String[1] $pem_key_group,
  String[1] $pem_key_mode,
  String[1] $pem_cert_owner,
  String[1] $pem_cert_group,
  String[1] $pem_cert_mode,
) {
  file { "${title} pkcs12_cert":
    path    => $pkcs12_path,
    ensure  => file,
    content => base64('decode', "${lookup($pkcs12_azure_cert).unwrap}")
  }

  # this define was originally 'openssl::export::pem_key'
  #   mod 'puppet-openssl', '2.0.1'
  # but the 'creates' attribute was not allowing certs to be extracted
  # on update. uses 'refreshonly' instead
  #
  util::openssl::pem_key { "${title} cert_key":
    ensure    => 'present',
    pfx_cert  => $pkcs12_path,
    pem_key   => $pem_key_path,
    in_pass   => '',
    subscribe => File["${title} pkcs12_cert"],
  }

  # this define was originally 'openssl::export::pem_cert'
  #   mod 'puppet-openssl', '2.0.1'
  # but the 'creates' attribute was not allowing certs to be extracted
  # on update. uses 'refreshonly' instead
  #
  util::openssl::pem_cert { "${title} cert":
    ensure   => 'present',
    pfx_cert => $pkcs12_path,
    pem_cert => $pem_cert_path,
    in_pass  => '',
    subscribe => File["${title} pkcs12_cert"],
  }

  file { "${title} pem_cert":
    ensure  => present,
    path    => $pem_cert_path,
    owner   => $pem_cert_owner,
    group   => $pem_cert_group,
    mode    => $pem_cert_mode,
    require => Util::Openssl::Pem_cert["${title} cert"],
    #    require => Openssl::Export::Pem_cert["${title} cert"],
  }

  file { "${title} pem_key":
    ensure => present,
    path   => $pem_key_path,
    owner  => $pem_key_owner,
    group  => $pem_key_group,
    mode   => $pem_key_mode,
    require => Util::Openssl::Pem_key["${title} cert_key"],
    #    require => Openssl::Export::Pem_key["${title} cert_key"],
  }

}
