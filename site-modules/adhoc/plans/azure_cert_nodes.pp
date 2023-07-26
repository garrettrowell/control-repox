# @summary lookup certificate from azure key_vault, base64 decode the result
#
plan adhoc::azure_cert_nodes(
  TargetSpec $targets,
  String $secret,
  String $pkcs12_location,
  String $pem_cert_location,
  String $pem_key_location,
) {

  $cert_from_azure = lookup($secret).unwrap
  run_command("echo '${cert_from_azure}' | openssl enc -base64 -d -A > ${pkcs12_location}", $targets, _description => "base64 decode ${secret} and write to ${pkcs12_location}")
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_cert_location} -nokeys -passin pass:''", $targets, _description => "extract ${pem_cert_location} from ${pkcs12_location}")
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_key_location} -nocerts -passin pass:'' -nodes", $targets, _description => "extract ${pem_key_location} from ${pkcs12_location}")

}
