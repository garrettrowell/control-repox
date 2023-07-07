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
  # Check for a external 'fail_catalog' fact to manually trigger catalog failure
  if $facts['fail_catalog'] == 'true' {
    fail('i was told to fail...')
  }

  # if trusted extension of pp_role is set include that role, otherwise ensure default role assigned
  if $trusted['extensions']['pp_role'] != undef {
    # Sanatize pp_role to ensure all lowercase characters and only acceptable characters used.
    #   See: https://www.puppet.com/docs/puppet/7/lang_reserved.html#lang_acceptable_char-classes-and-defined-resource-type-names
    #   Uacceptable characters replaced with '_'
    #
    $down_role = downcase($trusted['extensions']['pp_role'])
    $role_clean = regsubst($down_role, /[^a-z0-9_]/, '_', 'G')

    include "role::${role_clean}"

    $atest = 'a-poor::nested'
    $down_test = downcase($atest)
    $down_split = split($down_test, '::')
    $down_clean = $down_split.map |$elm| { regsubst($elm, /[^a-z0-9_]/, '_', 'G') }
    $down_join = join($down_clean, '::')
    echo { "testing -> ${down_join}": }
  } else {
    include role::default
  }
}

node 'pe-primary.garrett.rowell' {
  # Override PE managed rule to allow the primary server to request
  #   catalogs for any node. This should be removed once migration
  #   is complete
  Pe_puppet_authorization::Rule <| title == 'puppetlabs catalog' |> {
    allow => [$trusted['certname'], '$1'],
  }
}
