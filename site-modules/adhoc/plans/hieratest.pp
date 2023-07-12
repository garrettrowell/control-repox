# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
) {

  $test_secret = apply(get_target('pe-primary.garrett.rowell')) {
    notify { 'test-secret':
      message => "${lookup('test-secret').unwrap}"
    }
  }
  $retrieved_test_secret = $test_secret.to_data[0]['value']['report']['resource_statuses']#[0]['events']['desired_value']
  out::message($retrieved_test_secret)
  #$test = lookup('test_secret')
  #out::message($test)
  #$test_pass = lookup('atest')

  # out::message($test_pass)

}
