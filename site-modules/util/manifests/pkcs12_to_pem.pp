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
  String[1] $pkcs12_owner,
  String[1] $pkcs12_group,
  String[1] $pkcs12_mode,
  Optional[String] $cert_version = undef
) {

  $cert_from_azure = $cert_version ? {
    undef   => lookup($pkcs12_azure_cert),
    default => azure_key_vault::secret('growell-vault', 'test-cert', {
      vault_api_version             => '7.4',
      service_principal_credentials => {
        tenant_id     => lookup('azure_tenant_id'),
        client_id     => lookup('azure_client_id'),
        client_secret => lookup('azure_client_secret').unwrap,
      }
    }, $cert_version)
  }

  file { "${title} pkcs12_cert":
    ensure  => file,
    owner   => $pkcs12_owner,
    group   => $pkcs12_group,
    mode    => $pkcs12_mode,
    path    => $pkcs12_path,
    content => base64('decode', "${cert_from_azure}.unwrap}"),
    #    content => base64('decode', "${lookup($pkcs12_azure_cert).unwrap}")
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
