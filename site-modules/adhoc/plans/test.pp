# This is a description for my plan
plan adhoc::test(
  # input parameters go here
  TargetSpec $targets,
) {

  $pass = lookup('test-cert')
  out::message("${pass.unwrap}")
  # plan steps go here

}
