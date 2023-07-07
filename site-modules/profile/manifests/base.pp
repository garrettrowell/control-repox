# The base profile should include component modules that will be on all nodes
class profile::base {
  case $facts['os']['family'] {
    'RedHat': {
      include profile::base::redhat
    }
    'Debian', 'Ubuntu': {
      include profile::base::debian
    }
    'windows': {
      include profile::base::windows
    }
    default: {
      fail("${facts['os']['family']} is currently not supported.")
    }
  }
}
