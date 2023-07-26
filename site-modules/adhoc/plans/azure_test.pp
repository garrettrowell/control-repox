# This is a description for my plan
plan adhoc::azure_test(
  # input parameters go here
  TargetSpec $targets,
  String $secret,
  String $pkcs12_location,
  String $pem_cert_location,
  String $pem_key_location,
) {

  $cert_from_azure = lookup($secret).unwrap
  run_command("openssl enc -base64 -d -A <<< '${cert_from_azure}' > ${pkcs12_location}", $targets)
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_cert_location} -nokeys -passin pass:''", $targets)
  run_command("openssl pkcs12 -in ${pkcs12_location} -out ${pem_key_location} -nocerts -passin pass:'' -nodes", $targets)

}
