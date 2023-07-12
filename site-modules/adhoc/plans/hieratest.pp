# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
) {

  get_targets('pe-primary.garrett.rowell').each |$target| {
    $test_pass = apply($target) {
      lookup('test_password')
    }
    out::message($test_pass)

  }
  #$test_pass = lookup('atest')

  # out::message($test_pass)

}
