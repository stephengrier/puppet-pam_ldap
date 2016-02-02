# == Type: pam_ldap::pam

define pam_ldap::pam (
  $ensure    = 'present',
  $type      = undef,
  $control   = undef,
  $arguments = undef,
  $position  = undef,
) {
    pam { "Enable pam_ldap in ${name} auth":
      ensure    => $ensure,
      service   => $name,
      type      => $type,
      control   => $control,
      module    => 'pam_ldap.so',
      arguments => $arguments,
      position  => $position,
    }
}

