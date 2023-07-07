class role::default () {
  echo { 'hello from role::default': }
  include profile::base
}
