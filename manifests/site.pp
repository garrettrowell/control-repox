## site.pp ##

# This file (./manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
# https://puppet.com/docs/puppet/latest/dirs_manifest.html
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition if you want to use it.

## Active Configurations ##

# Disable filebucket by default for all File resources:
# https://github.com/puppetlabs/docs-archive/blob/master/pe/2015.3/release_notes.markdown#filebucket-resource-no-longer-created-by-default
File { backup => false }

## Node Definitions ##

# The default node definition matches any node lacking a more specific node
# definition. If there are no other node definitions in this file, classes
# and resources declared in the default node definition will be included in
# every node's catalog.
#
# Note that node definitions in this file are merged with node data from the
# Puppet Enterprise console and External Node Classifiers (ENC's).
#
# For more on node definitions, see: https://puppet.com/docs/puppet/latest/lang_node_definitions.html
node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
  if $facts['fail_catalog'] == 'true' {
    fail('i was told to fail...')
  }
}

node 'pe-primary.garrett.rowell' {
  # Override PE managed rule to allow the primary server to also
  #   upload facts for a node. This should be removed once migration
  #   is complete
  #  Pe_puppet_authorization::Rule <| title == 'puppetlabs facts' |> {
  #    allow => [$trusted['certname'], '$1'],
  #  }

  # temp allow primary to v3 catalog
  Pe_puppet_authorization::Rule <| title == 'puppetlabs catalog' |> {
    allow => [$trusted['certname'], '$1'],
  }


  puppet_authorization::rule { 'catalog-diff certless catalog':
    ensure               => absent,
    match_request_path   => '^/puppet/v4/catalog',
    match_request_type   => 'regex',
    match_request_method => 'post',
    allow                => $trusted['certname'],
    sort_order           => 500,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify               => Service['pe-puppetserver'],
  }
}

#node 'pe-nixagent-0.garrett.rowell' {
#  class { 'puppet_agent':
#    package_version => '6.28.0',
#  }
#  
#  package { 'pe-client-tools':
#    ensure => present,
#    install_options => ['--disablerepo=*', '--enablerepo=pc_repo'],
#  }
#}
