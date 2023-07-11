class profile::base::windows {
  echo { 'hello from profile::base::windows': }
  include chocolatey
  package { '7zip':
    ensure   => '23.1.0',
    provider =>  'chocolatey'
  }
}
