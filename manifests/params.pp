# == Class: pam_ldap::params

class pam_ldap::params {

  case $::osfamily {
    debian: {
      $packages = [ 'libpam-ldap' ]
      $pam_ldap_conf = '/usr/share/libpam-ldap/ldap.conf'
      $secret_file = '/usr/share/libpam-ldap/ldap.secret'
    }
    redhat: {
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $packages = [ 'nss-pam-ldapd' ]
      } else {
        $packages = [ 'pam_ldap' ]
      }
      $pam_ldap_conf = '/etc/pam_ldap.conf'
      $secret_file = '/etc/pam_ldap.secret'
    }
    default: {
      fail("Module ${module_name} does not support ${::osfamily}/${::operatingsystem}") # lint:ignore:80chars
    }
  }

  $default_options = {
    'timelimit'      => '30',
    'bind_timelimit' => '30',
    'idle_timelimit' => '3600',
    'uri'            => 'ldaps://127.0.0.1/',
    'base'           => 'ou=people,dc=example,dc=com',
  }
}

