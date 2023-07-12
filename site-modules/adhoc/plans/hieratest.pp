# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
) {

  #  $test_pass = lookup('test_password')
  $test_pass = lookup('atest')

  out::message($test_pass)

}
