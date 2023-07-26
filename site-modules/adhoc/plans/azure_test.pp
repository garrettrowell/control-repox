# This is a description for my plan
plan adhoc::azure_test(
  # input parameters go here
  TargetSpec $targets,
  String $secret,
  String $pkcs12_location,
) {

  #  $targets = get_targets($target)
  $cert_from_azure = lookup($secret).unwrap
  run_command("openssl enc -base64 -d -A <<< '${cert_from_azure}' > ${pkcs12_location}", $targets)

}
