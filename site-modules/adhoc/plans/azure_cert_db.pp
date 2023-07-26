# @summary retrieve pkcs12 certificate from azure key vault, base64 decode the result, and extract cert and key in pem format
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
# @param datacenter
#   which datacenter to discover specific target nodes from
#
plan adhoc::azure_cert_db(
  String $secret,
  String $pkcs12_location,
  String $pem_cert_location,
  String $pem_key_location,
  Enum['pe'] $datacenter,
) {

  $query = puppetdb_query("inventory[certname] { certname ~ \"${datacenter}-nixagent-\\\d+.*\"}")
  $names = $query.map |$r| { $r["certname"] }
  $targets = get_targets($names)
  out::message("found ${targets.size} node(s): ${targets}")
  $cert_from_azure = lookup($secret).unwrap
  run_command("openssl enc -base64 -d -A <<< '${cert_from_azure}' > ${pkcs12_location}", $targets, _description => "base64 decode ${secret} and write to ${pkcs12_location}")
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_cert_location} -nokeys -passin pass:''", $targets, _description => "extract ${pem_cert_location} from ${pkcs12_location}")
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_key_location} -nocerts -passin pass:'' -nodes", $targets, _description => "extract ${pem_key_location} from ${pkcs12_location}")

}
