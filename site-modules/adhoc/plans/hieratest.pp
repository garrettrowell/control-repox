# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
  String $lookup_secret,
  Enum['certificate','secret'] $type = 'secret', # default to secret but allow certs
) {

  # lookup the desired secret on the primary server because we assume the actual target(s) won't have a puppet agent
  $primary_server = 'pe-primary.garrett.rowell'
  $secret_block = apply(get_target($primary_server), _description => "lookup '${lookup_secret}' on ${primary_server}") {
    notify { $lookup_secret:
      message => "${lookup($lookup_secret).unwrap}"
    }
  }
  # take advantage of only ONE result block that always creates ONE corrective change
  $retrieved_secret = $secret_block.to_data[0]['value']['report']['resource_statuses']["Notify[${lookup_secret}]"]['events'][0]['desired_value']

  case $type {
    'secret': {
      #purely for development...
      out::message('secret')
      #      out::message($retrieved_secret)
      run_command("echo ${retrieved_secret}", $targets)
    }
    'certificate': {
      out::message('cert')
      $decoded_cert = base64('decode', $retrieved_secret)
      #out::message("${decoded_cert}")
      #run_command("echo ${decoded_cert}", $targets)
      #write_file($decoded_cert, '/tmp/test_cert.pkcs12', $targets)
      run_command("tee /tmp/test_cert.pkcs12 <<< \"${retrieved_secret}\"", $targets)
    }
  }

}
