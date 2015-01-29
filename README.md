# puppet-iaas

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with iaas](#setup)
    * [What iaas affects](#what-iaas-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with iaas](#beginning-with-iaas)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module allows deploying a highly-available installation of OpenStack Juno on commodity servers (only one NIC and one disk).

## Module Description

Four types of nodes are created for the deployment :

* Endpoint nodes that host load balancers and L2/L3 (Open vSwitch) routing and DHCP services 
* Controller nodes that hosts API services, databases, message queues, caches, and every 
* Storage nodes that hosts volumes, image storage, objects using Ceph
* Compute nodes to run guest operating systems

## Setup

### Setup Requirements
This module assumes nodes running Ubuntu 14.04 (Trusty) with either Puppet Enterprise or Puppet. Puppet must have pluginsync and storeconfigs enabled.

This module depends on Hiera.
 
### Beginning with puppet-iaas
To ensure high availability, three storage nodes, three controller nodes and two endpoint nodes must be deployed, be sure to have eight available servers.

## Usage

### Hiera Configuration

The first step to using the iaas-puppet module is to configure hiera with settings specific to your installation. In this module, the `examples` directory contains sample common.yaml file with all of the settings required by this module, as well as node configuration samples to test your deployment with. These configuration options include network settings, locations of specific nodes, and passwords. If any of these settings are undefined or not properly set, your deployment may fail.

### Site configuration
You then have to write your `site.pp` according to your deployment. Below is an example :

```
Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}

node /^ceph-\d+.iaas$/ {
  include 'iaas::role::storage'
}

node /^endpoint-\d+.iaas$/ {
  include 'iaas::role::endpoint'
}

node /^controller-\d+.iaas$/ {
  include 'iaas::role::controller'
}

node /^compute-\d+.iaas$/ {
  include 'iaas::role::compute'
}
```

The nodes should be deployed in the following order : storage nodes, endpoints, controllers and then compute nodes.

### Balancing the endpoint nodes

In order to balance requests across the different endpoints nodes, several solutions could be imagined but I believe that DNS Round-Robin is the easiest solution.

## Limitations

This module is still under development and doesn't include every feature yet.
