# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
) {

  $lookup_secret = 'test-secret'
  $secret_block = apply(get_target('pe-primary.garrett.rowell')) {
    notify { $lookup_secret:
      message => "${lookup($lookup_secret).unwrap}"
    }
  }
  $retrieved_secret = $secret_block.to_data[0]['value']['report']['resource_statuses']["Notify[${lookup_secret}]"]['events']
  out::message($retrieved_secret)
  #$test = lookup('test_secret')
  #out::message($test)
  #$test_pass = lookup('atest')

  # out::message($test_pass)

}
