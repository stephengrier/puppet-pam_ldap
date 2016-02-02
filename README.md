# pam_ldap

#### Table of Contents

1. [Module Description](#module-description)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Reference](#reference)

## Module Description

Puppet module for managing pam_ldap PAM module configuration.

This module can be used to configure the pam_ldap PAM module. The values in
pam_ldap.conf can be specified by passing a hash structure via the options
parameter. The options hash can contain any valid pam_ldap.conf setting.

The pam_ldap module can also be enabled in one or more PAM services in
/etc/pam.d/. This requires the herculesteam/augeasproviders_pam module. By
default pam_ldap is not enabled in any PAM service, but PAM service entries
can be specified by passing a hash structure via the pam_entries parameter.

## Requirements

* herculesteam-augeasproviders_pam
* stephengrier-cacerts
* puppetlabs-stdlib

## Usage

```puppet
 $options = {
   'timelimit' => '120',
   'tls_cacertdir' => '/etc/openldap/cacerts',
 }
 $pam_entries = {
   'system-auth' => {
     'type' => 'auth',
     'control' => 'sufficient',
     'arguments' => 'use_first_pass',
     'position' => 'before module pam_deny.so',
   }
 }
 pam_ldap {
   cacerts_dir => '/etc/openldap/cacerts',
   cacerts_source => 'puppet://filestore/certificates/foo.pem',
   options => $options,
   pam_entries => $pam_entries,
 }
```

Or alternatively you can pass parameters as hieradata:

```yaml
pam_ldap::options:
  'timelimit': '120'
  'tls_cacertdir': '/etc/openldap/cacerts'
pam_ldap::pam_entries:
  'system-auth':
    'type': 'auth'
    'control': 'sufficient'
    'arguments': 'use_first_pass'
    'position': 'before module pam_deny.so'
pam_ldap::cacerts_source: 'puppet://filestore/certificates/foo.pem'
```

## Reference

Classes:

* [pam_ldap](#class-pam_ldap)
* [pam_ldap::params](#class-pam_ldap::params)

Types:

* [pam_ldap::pam](#type-pam_ldap::pam)

### Class: pam_ldap

##### cacerts_dir

The directory containing the CA certificate for the LDAP server.
Default: /etc/openldap/cacerts

#### cacerts_source

The CA certificate file source.
Default: undef

#### options

Hash structure containing pam_ldap.conf settings. This can contain any
valid settings in pam_ldap.conf. See example above.
Default: undef

#### pam_entries

Hash structure defining pam_ldap::pam resources. See example above.
Default: {}

### Type: pam_ldap::pam

This is basically a wrapper around the augeas pam provider. You probably won't
use this type directly, but rather it is used if you pass the pam_entries hash
to the pam_ldap class.

#### ensure

Present or absent.

Default: present

#### type

The PAM management group the rule corresponds to. Valid values are `auth`, `account`,
`password` and `session`.
Default: undef

#### control

The PAM control, eg. `required`, `requisite`, `sufficient`, `optional`, etc.
Default: undef

#### arguments

Any PAM module arguments, eg. `use_first_pass` etc.
Default: undef

#### position

A three part text field that providers the placement position of an entry.

The field consists of `placement identifier value`

Placement can be either `before` or `after`
Identifier can be either `first`, `last`, `module`, or an Augeas xpath
Value is matched as follows:
  With `first` and `last` match `value` to the `control` field, can be blank for absolute positioning.
  With `module` matches the `module` field of the associated line, can not be blank.
  With an Augeas xpath this field will be ignored, and should be blank.

Default: undef

