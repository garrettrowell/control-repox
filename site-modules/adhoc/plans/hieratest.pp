# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
) {

  $test_pass = apply(get_target('pe-primary.garrett.rowell')) {
    return(lookup('test-secret').unwrap)
    #echo { 'test_password':
    #  message => lookup('test_password').unwrap
    #}
  }
  out::message($test_pass)
  #$test = lookup('test_secret')
  #out::message($test)
  #$test_pass = lookup('atest')

  # out::message($test_pass)

}
