# This is a description for my plan
plan adhoc::test(
  # input parameters go here
  TargetSpec $targets,
) {

  $pass = lookup('test_password')
  out::message("${pass}")
  # plan steps go here

}
