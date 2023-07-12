# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
) {

  get_targets('pe-primary.garrett.rowell').each |$target| {
    apply($target) {
      $test_pass = lookup('test_password')
    }
  }
  #$test_pass = lookup('atest')

  out::message($test_pass)

}
