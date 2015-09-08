[ProfitBricks SDK for Ruby](https://github.com/profitbricks/profitbricks-sdk-ruby) is a Ruby library used for interacting with the ProfitBricks platform over the REST API.

This guide will show you how to programmatically use the ProfitBricks library to perform common management tasks also available through the ProfitBricks Data Center Designer.

## Table of Contents

* [Concepts](#concepts)
* [Getting Started](#getting-started)
* [Installation](#installation)
* [Authentication](#authentication)
* [Configuration](#configuration)
* [How To: Create a Data Center](#how-to-create-a-data-center)
* [How To: Delete a Data Center](#how-to-delete-a-data-center)
* [How To: Create a Server](#how-to-create-a-server)
* [How To: List Available Disk and ISO Images](#how-to-list-available-disk-and-iso-images)
* [How To: Create a Storage Volume](#how-to-create-a-storage-volume)
* [How To: Update Cores, Memory, and Disk](#how-to-update-cores-memory-and-disk)
* [How To: Attach and Detach a Storage Volume](#how-to-attach-and-detach-a-storage-volume)
* [How To: List Servers, Volumes, and Data Centers](#how-to-list-servers-volumes-and-data-centers)
* [How To: Reserve IP Blocks and Create a LAN](#how-to-reserve-ip-blocks-and-create-a-lan)
* [How To: Create Additional Network Interfaces](#how-to-create-additional-network-interfaces)
* [Additional Documentation and Support](#additional-documentation-and-support)

--------------

## Concepts

The ProfitBricks SDK library wraps the [ProfitBricks REST API](/api/rest/) and provides a number of helper methods. All API operations are performed over SSL and authenticated using your ProfitBricks Data Center Designer credentials. The API can be accessed within an instance running in ProfitBricks or directly over the Internet from any application that can send an HTTPS request and receive an HTTPS response.

## Getting Started

Before you begin, you will need to [sign-up](https://www.profitbricks.com/signup) for a ProfitBricks account. The credentials you create during sign-up process will be used to authenticate against the API.
 
### Installation

The ProfitBricks SDK for Ruby is available as a gem. The latest stable version can be installed using the gem command syntax:

    gem install profitbricks-sdk-ruby

### Authentication

Once installed, the gem can now be loaded within Ruby.

    require 'profitbricks'

The connection and authentication config must first be specified before the library can connect to the ProfitBricks REST API. These are specified using the configuration method.

    ProfitBricks.configure do |config|
      config.username = 'username'
      config.password = 'password'
    end

**Caution:** You will want to ensure you follow security best practices when using credentials within your code.

### Configuration

Here is a list and brief description of available configuration parameters:

* ```url``` - URL of the ProfitBricks REST API, default: "https://api.profitbricks.com"
* ```username``` - ProfitBricks username (required)
* ```password``` - ProfitBricks password (required)
* ```path_prefix``` - REST URI path, default: "/rest/"
* ```headers``` - Custom HTTP request headers
* ```global_classes``` - Disable (flatten) ProfitBricks class namespace; set to false to avoid name conflicts, default: true
* ```timeout``` - Timeout value for wait_for() method, default 60 seconds
* ```interval``` - Polling interval value for wait_for() method, default: 3 seconds
* ```debug``` - Enable or disable Excon debugging, default: false

Example usage:

    ProfitBricks.configure do |config|
      config.username = 'username'
      config.password = 'password'
      config.url = 'https://api.profitbricks.com'
      config.path_prefix = '/rest/'
      config.timeout = 120
      config.interval = 1
    end

## How To: Create a Data Center

ProfitBricks introduces the concept of Virtual Data Centers. These are logically separated from one another and allow you to have a self-contained environment for all servers, volumes, networking, snapshots, and so forth. The goal is to give you the same experience as you would have if you were running your own physical data center.

Unless you plan to manage an existing ProfitBricks environment, the first step will typically involve choosing the location for a new virtual data center. A list of locations can be obtained with Location class and the desired location assigned to a variable for later reference.

    Location.list.each { |location| puts "#{location.id} - #{location.properties['name']}" }
    location = Location.get('us/las')

And now the data center can be created. 

    datacenter = Datacenter.create(name: 'datacenter1', description: 'My New Datacenter', location: location.id)
    datacenter.wait_for { ready? }

The ```wait_for``` server object method will wait until the request status is done before continuing. This is useful when chaining requests together that are dependent on one another.

## How To: Delete a Data Center

You will want to exercise a bit of caution here. Removing a data center will **destroy** all objects contained within that data center -- servers, volumes, snapshots, and so on. The objects -- once removed -- will be unrecoverable. 

The code to remove a data center is as follows. This example assumes you want to remove a data center named 'datacenter1': 

    name = 'datacenter1'
     
    datacenter = Datacenter.list.find { |datacenter| dc.properties['name'] = name }
    
    datacenter.delete

The data center can also be retrieved and removed by the UUID.

    datacenter = Datacenter.get('6ff3153b-2ecc-45b4-8d70-aa8ea9a285e3')
    
    datacenter.delete

## How To: Create a Server

The following example shows you how to create a new server in the virtual data center created above:

    server = datacenter.create_server(name: 'server1', description: 'My New Server', cores: 4, ram: 4096)
    server.wait_for { ready? }

One of the unique features of the ProfitBricks platform when compared with the other providers is that it allows you to define your own settings for cores, memory, and disk size without being tied to a particular size.

## How To: Create a Composite Server

A composite server is a server instance that has volumes and NICs already attached. The following example will demonstrate how a composite server can be built with a single request, but the volume, NICs, and included firewall rule will be defined separately for readability.

    volumes = [ { name: 'OS', size: 10, image: '4dc4585c-505a-11e5-bfc6-52540066fee9', bus: 'VIRTIO', imagePassword: 'secretpassword' } ]
    fwrules = [ { name: 'SSH', protocol: 'TCP', portRangeStart: 22, portRangeEnd: 22 } ]
    nics = [ { name: 'public', lan: 1, firewallrules: fwrules }, { name: 'private', lan: 2 } ]

The composite server can now be created.

    server = datacenter.create_server(name: 'Composite Server', cores: 1, ram: 1024, volumes: volumes, nics: nics)
    server.wait_for { ready? }

## How To: List Available Disk and ISO Images

A list of disk and ISO images are available from ProfitBricks for immediate use. These can be easily viewed and selected with the following code.

    Image.list
    
    image = Image.list.find { |image| image.name =~ /CentOS-6/ && image.type == "HDD" && image.region == "us/las" }

Make sure the image you retrieve is in the same location as the virtual data center.

## How To: Create a Storage Volume

ProfitBricks allows for the creation of multiple storage volumes that can be attached and detached as needed. It is useful to attach an image when creating a storage volume. The storage size is in gigabytes (GB).
 
    volume = datacenter.create_volume(name: 'My New Volume, size: 40, image: image.id)
    
    volume.wait_for { ready? }

## How To: Update Cores, Memory, and Disk

ProfitBricks allows users to dynamically update cores, memory, and disk independently of each other. This removes the restriction of needing to upgrade to the next size available size to receive an increase in memory. You can now simply increase the instances memory keeping your costs in-line with your resource needs.

**Note:** The memory parameter value must be a multiple of 256, e.g. 256, 512, 768, 1024, and so forth.

The following code illustrates how you can update cores and memory: 

    server.update(cores: 6, ram: 10240 }
    sever.wait_for { ready? }
    
The server object may need to be refreshed in order to show the new configuration.

    server.reload

 This is how you would update the storage volume size: 
 
    volume.update(size: 100)
    volume.wait_for { ready? }

## How To: Attach and Detach a Storage Volume

ProfitBricks allows for the creation of multiple storage volumes. You can detach and reattach these on the fly. This allows for various scenarios such as re-attaching a failed OS disk to another server for possible recovery or moving a volume to another location and bringing it online. 

The following illustrates how you would attach and detach a volume from a server:

    volume.attach(server.id)
    
    volume.wait_for { ready? }
    
    volume.detach(server.id)

## How To: List Servers, Volumes, LANs, NICs, and Data Centers

The library provides standard functions for retrieving a list of volumes, servers, network interfaces (NICs), and LANs. 

The following code illustrates how to list various resources under a specific data center.

    Datacenter.list
    datacenter = Datacenter.get('7ff3153b-2ecc-45b4-8d70-aa6ea9a23d5e4')
    
    datacenter.list_volumes
    datacenter.list_servers
    datacenter.list_lans

To list the volumes and NICs attached to a specific server:

    server = datacenter.get_server('4bf3153b-2ecc-45b4-8d70-aa8ea9a285e3')
    
    server.list_volumes
    server.list_nics

## How To: Reserve IP Blocks and Create a LAN

The IP block size (number of IP addresses) and location are required to reserve an IP block:

    ipblock = IPBlock.reserve(location: 'us/las', size: 5)

A LAN must be created within a data center.
    
    lan = datacenter.create_lan(name: 'My LAN')
    lan.wait_for { ready? }

The LAN can be enabled for public Internet access if necessary.

    lan.update(public: true)

## How To: Create Additional Network Interfaces

The ProfitBricks platform supports adding multiple NICs to a server. These NICs can be used to create different, segmented networks on the platform.

The sample below shows you how to add a second NIC to an existing server and LAN:

    nic = server.create_nic(name: 'nic2', lan: lan.id, ips: ['10.2.2.3','10.2.3.4'])
    nic.wait_for { ready? }

## Additional Documentation and Support

Further documentation can be found in the project repository on GitHub.

    [https://github.com/StackPointCloud/profitbricks-sdk-ruby](https://github.com/StackPointCloud/profitbricks-sdk-ruby)

Questions and discussions can be directed to [ProfitBricks DevOps Central](https://devops.profitbricks.com/) site.
