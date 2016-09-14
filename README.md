[![Build Status](https://travis-ci.org/icann-dns/puppet-openbgpd.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-openbgpd)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/openbgpd.svg?maxAge=2592000)](https://forge.puppet.com/icann/openbgpd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/openbgpd.svg?maxAge=2592000)](https://forge.puppet.com/icann/openbgpd)
# OpenBGPd

### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with openbgpd](#setup)
    * [What openbgpd affects](#what-openbgpd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openbgpd](#beginning-with-openbgpd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage the installation and configuration of OpenBGPd (Routing Daemons) .

## Module Description

This modules allows for the manging of the openbgpd daemon.

## Setup

### What openbgpd affects

* Manages the openbgpd configueration file 

### Setup Requirements

* depends on stdlib 4.12.0 (may work with earlier versions)
* depends on icann-tea 0.2.2 (may work with earlier versions)

### Beginning with openbgpd

Install the package an make sure it is enabled and running with default options, this will just configure zebra to run with no bgp config:

```puppet 
class { '::openbgpd': }
```

With some bgp peers

```puppet
class { '::openbgpd': }
class { '::openbgpd::bgpd':
  my_asn => 64496,
  router_id => '192.0.2.1',
  networks4 => [ '192.0.2.0/24'],
  peers => {
    '64497' => {
      'addr4' => ['192.0.2.2'],
      'desc'  => 'TEST Network'
    }
  }
}  
```

and in hiera

```yaml
openbgpd::my_asn: 64496,
openbgpd::router_id: 192.0.2.1
openbgpd::networks4:
- '192.0.2.0/24'
openbgpd::peers:
  64497:
    addr4:
    - '192.0.2.2'
    desc: TEST Network
```

## Usage

Add config but disable advertisments and add nagios checks

```puppet
class { '::openbgpd::bgpd':
  my_asn => 64496,
  router_id => '192.0.2.1',
  networks4 => [ '192.0.2.0/24'],
  enable_advertisements => false,
  peers => {
    '64497' => {
      'addr4' => ['192.0.2.2'],
      'desc'  => 'TEST Network'
    }
  }
}  
```

Full config

```puppet
class { '::openbgpd::bgpd':
  my_asn                   => 64496,
  router_id                => '192.0.2.1',
  networks4                => [ '192.0.2.0/24', '10.0.0.0/24'],
  failsafe_networks4       => ['10.0.0.0/23'],
  networks6                => ['2001:DB8::/48'],
  failsafe_networks6       => ['2001:DB8::/32'],
  enable_advertisements    => false,
  enable_advertisements_v4 => false,
  enable_advertisements_v6 => false,
  peers => {
    '64497' => {
      'addr4'          => ['192.0.2.2'],
      'addr6'          => ['2001:DB8::2'],
      'desc'           => 'TEST Network',
      'inbound_routes' => 'all',
      'communities'    => ['no-export', '64497:100' ],
      'multihop'       => 5,
      'prepend'        => 3,
    }
  }
}  
```

## Reference


- [**Public Classes**](#public-classes)
    - [`openbgpd`](#class-openbgpd)
- [**Private defined types**](#private-defined-types)
    - [`openbgpd::peer`](#class-openbgpdbgpdpeer)

### Classes

### Public Classes

#### Class: `openbgpd`
  configure BGP settings
  
##### Parameters (all optional)

* `my_asn` (Int, Default: undef): The local ASN to use
* `router_id` (IP Address, Default: undef): IP address for the router ID
* `networks4` (Array, Default: []): Array ip IPv4 networks in CIDR format to configure
* `failsafe_networks4` (Array, Default: []): Array ip IPv4 failsafe networks in CIDR format to configure.  Failsafe networks consist of covering prefixes for the IPv4 networks.  if the policy decided to disable advertising due to detected errors it will leave the failsafe network inplace.  This is a specific use case for anycast networks which effectivly disables an anycast node as all others will still be advertising a more specific network; however if something goes wrong and all nodes have the most specific route removed then we would still have this failsafe network in place.  
* `networks6` (Array, Default: []): Array ip IPv6 networks in CIDR format to configure
* `failsafe_networks4` (Array, Default: []): Array ip IPv6 failsafe networks in CIDR format to configure.  See failsafe_networks4 for a description
* `failsafe_server` (Bool, Default: false): If this is set to true then we will only ever advertise the failsafe networks.  i.e. the node will be effectivly ofline unless all other nodes are either out of commision or remove ther most specific networks (`networks4` and `networks6`)
* `enable_advertisements` (Bool, Default: true): If this is set to false then no networks, including the failsafe networks, will be advertised.
* `enable_advertisements_v4` (Bool, Default: true): If this is set to false then no IPv4 networks, including the failsafe IPv4 networks, will be advertised.
* `enable_advertisements_v6` (Bool, Default: true): If this is set to false then no IPv6 networks, including the failsafe IPv6 networks, will be advertised.
* `conf_file` (Absolute file path, Default: '/etc/openbgpd/bgpd.conf'): The fully qualified path to the managed config file

#### Defined `openbgpd::peer`

Creat config for individual peers

##### Parameters 

* `namevar` (Int): ASN of the peer
* `addr4` (Array, Default: []): Array of IPv4 neighbor addresses
* `addr6` (Array, Default: []): Array of IPv6 neighbor addresses
* `desc` (String, Default: undef): Description of the peer
* `inbound_routes` (String /^(all|none|defaultv4|default|v6default)$/, Default: 'none'): what ACL to apply for inbound routes.  
    * all: accept all but the default route
    * none: accept no routes
    * default: only accept default routes
    * v4default: only accept default routes over ipv4
    * v6default: accept a default v6 route
* `communities` (Array, Default: []): Array of comminuties to set on advertised routes.
* `multihop` (Int, Default: undef): Multihop setting to set on peers neighbor addresses
* `prepend` (Int, Default: undef): Number of times to prepend your own ASN on advertised routes

## Limitations

This module has been tested on:

* FreeBSD 10

## Development

Pull requests welcome but please also update documentation and tests.
