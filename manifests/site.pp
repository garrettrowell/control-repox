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
    echo { 'im new': }
  #  echo { 'im newer': }

  #  ini_setting {
  #    default:
  #      path    => '/etc/puppetlabs/puppet/puppet.conf',
  #      section => 'agent',
  #      setting => $title,
  #      ;
  #    'fact_value_length_soft_limit':
  #      value   => 1234,
  #      setting => $title,
  #
  #      ;
  #    'number_of_facts_soft_limit':
  #      value   => 4567,
  #      ;
  #  }

  # Check for a external 'fail_catalog' fact to manually trigger catalog failure
  if $facts['fail_catalog'] == 'true' {
    fail('i was told to fail...')
  }

  # if trusted extension of pp_role is set include that role, otherwise ensure default role assigned
  if $trusted['extensions']['pp_role'] != undef {
    # Sanatize pp_role to ensure all lowercase characters and only acceptable characters used.
    #   See: https://www.puppet.com/docs/puppet/7/lang_reserved.html#lang_acceptable_char-classes-and-defined-resource-type-names
    #
    # downcase the entire thing
    $role_downcase = downcase($trusted['extensions']['pp_role'])
    # create array of each namespace
    $role_split = split($role_downcase, '::')
    # substitute any invalid characters in each namespace with '_'
    $role_clean_elms = $role_split.map |$elm| { regsubst($elm, /[^a-z0-9_]/, '_', 'G') }
    # rebuild expected name::space format
    $role_clean = join($role_clean_elms, '::')
    # prefix with the role namespace, because this is the standard i've elected to follow
    $role_final = "role::${role_clean}"

    # Attempt to include the role
    $included_exists = safe_include($role_final)

    # if the role doesn't exist safe_include returns undef
    # in which case alert the user and include 'role::default' instead
    if $included_exists == undef {
      echo { "'${role_final}' does not exist. Ensuring 'role::default' gets applied":
        loglevel => 'warning',
        withpath => false,
      }

      include role::default
    }
  } else {
    include role::default
  }

  # Playing with sensitive data
  #$pass = lookup('test_password')
  #echo { "wrapped_pass: ${pass}": }
  #echo { "unwrapped_pass: ${pass.unwrap}": }

  # Azure key vault - secret with hiera backend
  #echo { lookup('test-secret').unwrap: }

  # Azure key vault - Secret
  #$test_secret = azure_key_vault::secret('growell-vault', 'test-secret', {
  #  vault_api_version             => '7.4',
  #  service_principal_credentials => {
  #    tenant_id     => lookup('azure_tenant_id'),
  #    client_id     => lookup('azure_client_id'),
  #    client_secret => lookup('azure_client_secret').unwrap,
  #  }
  #})
  #
  #echo { "test_secret wrapped: ${test_secret}": }
  #echo { "test_secret unwrapped: ${test_secret.unwrap}": }

  # Azure key vault - Cert
  #   Can validate contents on *NIX with:
  #   openssl pkcs12 -in /tmp/test_cert.pkcs12 -info -nokeys
  #
  #$test_cert = azure_key_vault::secret('growell-vault', 'test-cert', {
  #  vault_api_version             => '7.4',
  #  service_principal_credentials => {
  #    tenant_id     => lookup('azure_tenant_id'),
  #    client_id     => lookup('azure_client_id'),
  #    client_secret => lookup('azure_client_secret').unwrap,
  #  }
  #})
  #
  ## base64 function from stdlib
  #file { '/tmp/test_cert.pkcs12':
  #  ensure  => file,
  #  content => base64('decode', "${test_cert.unwrap}")
  #}

}
#node 'pe-nixagent-0.garrett.rowell' {
#  include puppet_operational_dashboards
#}
#
#node 'pe-primary.garrett.rowell' {
#  include epp_demo
#  include dropsonde
#  include puppet_operational_dashboards::enterprise_infrastructure
#
#  # Override PE managed rule to allow the primary server to request
#  #   catalogs for any node. This should be removed once migration
#  #   is complete
#  Pe_puppet_authorization::Rule <| title == 'puppetlabs catalog' |> {
#    allow => [$trusted['certname'], '$1'],
#  }
#
#  #  # Authentication data required to configure azure_key_vault hiera backend
#  #  $azure_creds = {
#  #    'tenant_id'     => lookup('azure_tenant_id'),
#  #    'client_id'     => lookup('azure_client_id'),
#  #    'client_secret' => lookup('azure_client_secret').unwrap,
#  #  }
#  #
#  #  # Manage eyaml keys and azure_key_vault_credentials to allow use
#  #  #   with plans
#  #  $eyaml_private_key = "${settings::confdir}/eyaml/private_key.pkcs7.pem"
#  #  $eyaml_public_key  = "${settings::confdir}/eyaml/public_key.pkcs7.pem"
#  #
#  #  file {
#  #    default:
#  #      ensure => file,
#  #      owner  => 'pe-puppet',
#  #      group  => 'pe-orchestration-services',
#  #      mode   => '0440',
#  #    ;
#  #    "${settings::confdir}/azure_key_vault_credentials.yaml":
#  #      content => Sensitive(to_yaml($azure_creds)),
#  #    ;
#  #    [
#  #      $eyaml_private_key,
#  #      $eyaml_public_key,
#  #    ]:
#  #      # use defaults
#  #    ;
#  #    "${settings::confdir}/eyaml":
#  #      ensure => directory,
#  #      mode   => '0550',
#  #    ;
#  #  }
#  #
#  #  # Configure hiera-eyaml cli for convenience
#  #  file {
#  #    '/etc/eyaml':
#  #      ensure => directory,
#  #    ;
#  #    '/etc/eyaml/config.yaml':
#  #      ensure  => file,
#  #      content => to_yaml(
#  #        {
#  #          'pkcs7_private_key' => $eyaml_private_key,
#  #          'pkcs7_public_key'  => $eyaml_public_key,
#  #        }
#  #      ),
#  #    ;
#  #  }
#
#  #$test_pem = lookup('test2_cert')
#  #file { '/tmp/test.pem':
#  #  ensure  => file,
#  #  content => $test_pem.unwrap,
#  #  #    content => base64('decode', $test_pem.unwrap),
#  #}
#
#  #  util::pkcs12_to_pem { 'atest':
#  #    pkcs12_azure_cert => 'test-cert',
#  #    pkcs12_path       => '/tmp/atest.pkcs12',
#  #    pem_key_path      => '/tmp/atest.key',
#  #    pem_cert_path     => '/tmp/atest.pem',
#  #    pem_key_owner     => 'pe-puppet',
#  #    pem_key_group     => 'pe-puppet',
#  #    pem_key_mode      => '0600',
#  #    pem_cert_owner    => 'pe-puppet',
#  #    pem_cert_group    => 'pe-puppet',
#  #    pem_cert_mode     => '0600',
#  #    pkcs12_owner      => 'pe-puppet',
#  #    pkcs12_group      => 'pe-puppet',
#  #    pkcs12_mode       => '0600',
#  #    #    cert_version      => '12cdcded27284f4eb22988c861a7b74e'
#  #  }
#
#}
