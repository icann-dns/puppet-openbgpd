# == Class: openbgpd
#
class openbgpd (
  Openbgpd::Asn         $my_asn,
  Tea::Ipv4             $router_id,
  Array[Tea::Ipv4_cidr] $networks4                = [],
  Array[Tea::Ipv6_cidr] $networks6                = [],
  Array[Tea::Ipv4_cidr] $failsafe_networks4       = [],
  Array[Tea::Ipv6_cidr] $failsafe_networks6       = [],
  Array[Tea::Ipv4_cidr] $rejected_v4              = [],
  Array[Tea::Ipv6_cidr] $rejected_v6              = [],
  Boolean               $failover_server          = false,
  Boolean               $enable_advertisements    = true,
  Boolean               $enable_advertisements_v4 = true,
  Boolean               $enable_advertisements_v6 = true,
  Tea::Absolutepath     $conf_file                = '/usr/local/etc/bgpd.conf',
  String                $package                  = 'openbgpd',
  String                $service                  = 'openbgpd',
  Boolean               $enable                   = true,
  Boolean               $fib_update               = true,
  Hash[Openbgpd::Asn, Openbgpd::Peer] $peers      = {},
) {

  ensure_packages([$package])
  file {$conf_file:
    ensure  => present,
    content => template('openbgpd/usr/local/etc/bgpd.conf.erb'),
    mode    => '0400',
    require => Package[$package],
    notify  => Service[$service],
  }
  file {'/usr/local/bin/reload_bgp':
    ensure  => present,
    content => template('openbgpd/usr/local/bin/reload_bgp.erb'),
    mode    => '0500',
  }
  service { $service:
    ensure  => $enable,
    enable  => $enable,
    #restart => '/usr/local/bin/reload_bgp',
    require => File['/usr/local/bin/reload_bgp'],
  }
}
