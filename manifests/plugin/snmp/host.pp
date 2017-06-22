# https://collectd.org/wiki/index.php/Plugin:SNMP
define collectd::plugin::snmp::host (
  $collect,
  $ensure             = 'present',
  $address            = $name,
  $version            = '1',
  $interval           = undef,
  # SNMPv1/2c
  $community          = 'public',
  # SNMPv3
  $username           = undef,
  $security_level     = undef,
  $context            = undef,
  $auth_protocol      = undef,
  $auth_passphrase    = undef,
  $privacy_protocol   = undef,
  $privacy_passphrase = undef,
) {

  include ::collectd
  include ::collectd::plugin::snmp

  $conf_dir   = $collectd::plugin_conf_dir
  $root_group = $collectd::root_group

  file { "snmp-host-${name}.conf":
    ensure  => $ensure,
    path    => "${conf_dir}/25-snmp-host-${name}.conf",
    owner   => 'root',
    group   => $root_group,
    mode    => '0640',
    content => template('collectd/plugin/snmp/host.conf.erb'),
    notify  => Service['collectd'];
  }
}
