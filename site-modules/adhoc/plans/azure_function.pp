# @summary retrieve pkcs12 certificate from azure key vault, base64 decode the result, and extract cert and key in pem format
#
# @param targets
#   comma separated list of node(s) to write cert to
#
# @param secret
#   the certificate name to lookup in azure key vault
#
# @param pkcs12_location
#   the full path to write the base64 decoded pkcs12 cert to
#
# @param pem_cert_location
#   the full path to write the pem certificate to
#
# @param pem_key_location
#   the full path to write the pem key to
#
plan adhoc::azure_function(
  TargetSpec $targets,
  String $secret,
  String $pkcs12_location,
  String $pem_cert_location,
  String $pem_key_location,
  String $pem_key_owner,
  String $pem_key_group,
  String $pem_key_mode,
  String $pem_cert_owner,
  String $pem_cert_group,
  String $pem_cert_mode,
  String $pkcs12_owner,
  String $pkcs12_group,
  String $pkcs12_mode,
  Optional[String] $cert_version = undef,
) {

  apply_prep($targets)

  apply($targets) {
    util::pkcs12_to_pem { $secret:
      pkcs12_azure_cert => $secret,
      pkcs12_path       => $pkcs12_location,
      pem_key_path      => $pem_cert_location,
      pem_cert_path     => $pem_key_location,
      pem_key_owner     => $pem_key_owner,
      pem_key_group     => $pem_key_group,
      pem_key_mode      => $pem_key_mode,
      pem_cert_owner    => $pem_cert_owner,
      pem_cert_group    => $pem_cert_group,
      pem_cert_mode     => $pem_cert_mode,
      pkcs12_owner      => $pkcs12_owner,
      pkcs12_group      => $pkcs12_group,
      pkcs12_mode       => $pkcs12_mode,
      cert_version      => $cert_version
    }
  }

}
