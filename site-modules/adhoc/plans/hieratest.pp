# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
  String $lookup_secret,
  Enum['certificate','secret'] $type = 'secret', # default to secret but allow certs
) {

  # lookup the desired secret on the primary server because we assume the actual target(s) won't have a puppet agent
  $primary_server = 'pe-primary.garrett.rowell'
  $secret_block = apply(get_target($primary_server), _description => "lookup '${lookup_secret}' on ${primary_server}", _catch_errors => true) {
    notify { $lookup_secret:
      message => "${lookup($lookup_secret).unwrap}"
    }
  }

  # if lookup successful
  if $secret_block.ok {
    # take advantage of only ONE result block that always creates ONE corrective change
    $retrieved_secret = $secret_block.to_data[0]['value']['report']['resource_statuses']["Notify[${lookup_secret}]"]['events'][0]['desired_value']

    case $type {
      'secret': {
        get_targets($targets).each |$target| {
          run_command("printf '${retrieved_secret}'", $target, "printf ${lookup_secret} on ${target}")
        }
      }
      'certificate': {
        $certfile = '/tmp/test_cert.pkcs12'
        get_targets($targets).each |$target| {
          run_command("base64 --decode <<< '${retrieved_secret}' > ${certfile}", $target, "write certificate to ${certfile} on ${target}")
          run_command("openssl pkcs12 -in ${certfile} -info -nokeys -passout pass: -passin pass:''", $target, "reading ${certfile} on ${target}")
        }
      }
    }
  } else {
    $err = $secret_block[0]['_error']
    out::message("${err['kind']}, ${err['msg']}")
  }

}
