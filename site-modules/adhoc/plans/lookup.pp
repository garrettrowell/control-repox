# @summary Lookup some 'secret' via hiera lookup outside of apply block
#
# @param secret
#   the secret to lookup
#
plan adhoc::lookup(
  String[1] $secret,
) {

  $pass = lookup($secret)

  out::message("wrapped: ${pass}")
  out::message("unwrapped: ${pass.unwrap}")

}
