# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include epp_demo
class epp_demo (
  String $schedule_zone_id,
  String $log_level,
  String $log_dir,
  String $log_target,
){
  file { '/tmp/test':
    ensure  => 'file',
    content => epp('epp_demo/test.epp'),
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
  }
}
