# This is a description for my plan
plan adhoc::azure_cert_db(
  String $secret,
  String $pkcs12_location,
  String $pem_cert_location,
  String $pem_key_location,
  Enum['pe'] $datacenter,
) {

  $query = puppetdb_query("inventory[certname] { certname ~ \"${datacenter}-nixagent-\\d+.*\"}")
  $names = $query.map |$r| { $r["certname"] }
  $targets = get_targets($names)
  out::message("found ${targets.size} node(s): ${targets}")
  $cert_from_azure = lookup($secret).unwrap
  run_command("openssl enc -base64 -d -A <<< '${cert_from_azure}' > ${pkcs12_location}", $targets, _description => "base64 decode ${secret} and write to ${pkcs12_location}")
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_cert_location} -nokeys -passin pass:''", $targets, _description => "extract ${pem_cert_location} from ${pkcs12_location}")
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_key_location} -nocerts -passin pass:'' -nodes", $targets, _description => "extract ${pem_key_location} from ${pkcs12_location}")

}
