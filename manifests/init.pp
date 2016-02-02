# == Class: pam_ldap
#
# Puppet module for managing pam_ldap PAM module configuration.
#
# This module can be used to configure the pam_ldap PAM module. The values in
# pam_ldap.conf can be specified by passing a hash structure via the options
# parameter. The options hash can contain any valid pam_ldap.conf setting.
#
# The pam_ldap module can also be enabled in one or more PAM services in
# /etc/pam.d/. This requires the herculesteam/augeasproviders_pam module. By
# default pam_ldap is not enabled in any PAM service, but PAM service entries
# can be specified by passing a hash structure via the pam_entries parameter.
#
# === Examples
#
#  $options = {
#    'timelimit' => '120',
#    'tls_cacertdir' => '/etc/openldap/cacerts',
#  }
#  $pam_entries = {
#    'system-auth' => {
#      'type' => 'auth',
#      'control' => 'sufficient',
#      'arguments' => 'use_first_pass',
#      'position' => 'before module pam_deny.so',
#    }
#  }
#  pam_ldap {
#    cacerts_dir => '/etc/openldap/cacerts',
#    cacerts_source => 'puppet://filestore/certificates/foo.pem',
#    options => $options,
#    pam_entries => $pam_entries,
#  }
#
# Or alternatively you can pass parameters as hieradata:
#
# pam_ldap::options:
#   'timelimit': '120'
#   'tls_cacertdir': '/etc/openldap/cacerts'
# pam_ldap::pam_entries:
#   'system-auth':
#     'type': 'auth'
#     'control': 'sufficient'
#     'arguments': 'use_first_pass'
#     'position': 'before module pam_deny.so'
# pam_ldap::cacerts_source: 'puppet://filestore/certificates/foo.pem'
#
# === Parameters
#
# [*cacerts_dir*]
#   The directory containing the CA certificate for the LDAP server.
#   Default: /etc/openldap/cacerts
#
# [*cacerts_source*]
#   The CA certificate file source.
#   Default: undef
#
# [*options*]
#   Hash structure containing pam_ldap.conf settings. This can contain any
#   valid settings in pam_ldap.conf. See example above.
#   Default: undef
#
# [*pam_entries*]
#   Hash structure defining pam_ldap::pam resources. See example above.
#   Default: {}
#
# === Dependencies
#
# herculesteam-augeasproviders_pam
# stephengrier-cacerts
# puppetlabs-stdlib
#
# === Authors
#
# Stephen Grier <git at grier.org.uk>
#
# lint:ignore:class_inherits_from_params_class
class pam_ldap (
  $cacerts_dir = '/etc/openldap/cacerts',
  $cacert_source = undef,
  $options = undef,
  $pam_entries = {},
) inherits pam_ldap::params {

  # Merge hashes from multiple layer of hierarchy in hiera.
  $hiera_options = hiera_hash("${module_name}::options", undef)

  $tmp_options = $hiera_options ? {
    undef   => $options,
    default => $hiera_options,
  }

  $merged_options = merge($::pam_ldap::params::default_options, $tmp_options)

  # Install required packages.
  package { $::pam_ldap::params::packages: ensure => 'present' }

  # Install a file containing the CA cert for the LDAP server if required.
  if $cacert_source {
    cacerts::cacert { 'openldap-ca':
      cacerts_dir => $cacerts_dir,
      source      => $cacert_source,
    }
  }

  # The main pam_ldap.conf file.
  file { 'pam_ldap.conf':
    ensure  => 'file',
    path    => $::pam_ldap::params::pam_ldap_conf,
    content => template('pam_ldap/pam_ldap.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # If a rootbindpw is needed place it in the pam_ldap.secret file.
  if $merged_options['rootbindpw'] {
    file { 'pam_ldap.secret':
      ensure  => 'file',
      path    => $::pam_ldap::params::secret_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $merged_options['rootbindpw'],
    }
  }

  # Optionally enable pam_ldap in PAM services.
  create_resources('pam_ldap::pam', $pam_entries)

}

# lint:endignore
