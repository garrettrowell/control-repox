# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
) {

  $result = get_targets('pe-primary.garrett.rowell').each |$target| {
    $test_pass = apply($target) {
      echo { 'test_password':
        msg => lookup('test_password').unwrap
      }
    }
    #    out::message($test_pass)
  }
  out::message($result)
  #$test = lookup('test_secret')
  #out::message($test)
  #$test_pass = lookup('atest')

  # out::message($test_pass)

}
