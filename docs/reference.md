
# Table of Contents

* [Resource Methods](#resource-methods)
* [Datacenter](#datacenter)
* [Server](#server)
    * [Server Volumes](#server-volumes)
    * [Server CD-ROMs](#server-cd-roms)
* [NIC](#nic)
* [Firewall Rule](#firewall-rule)
* [Volume](#volume)
* [Loadbalancer](#loadbalancer)
* [LAN](#lan)
* [Location](#location)
* [IP Block](#ip-block)
* [Image](#image)
* [Snapshot](#snapshot)
* [Request](#request)

# Resource Methods

```wait_for(timeout, interval)``` - Poll a resource until the **DONE** status is returned.

    datacenter = Datacenter.create(name: "dc1", location: "us/las")
    datacenter.wait_for( { ready? }
    server = datacenter.create(name: "server1", cores: 1, ram: 1024)
    server.wait_for { ready? }

```reload``` - Retrieve latest properties of a resource.

    datacenter.reload
    server.reload

# Datacenter

List all datacenters:

    Datacenter.list

Retrieve a single datacenter:

    datacenter = Datacenter.get(datacenter_id)

Create a datacenter:

    datacenter = Datacenter.create(name: "dc1", description: "My Datacenter", location: "las/us")

Update a datacenter:

    datacenter.update(description: "New datacenter description")

Remove a datacenter:

    datacenter.delete

# Server

List all servers within a datacenter:

    datacenter = Datacenter.get(datacenter_id)
    servers = datacenter.list_servers

Retrieve a server within a datacenter:

    datacenter = Datacenter.get(datacenter_id)
    server = datacenter.get_server(server_id)

Create a server:

    datacenter = Datacenter.get(datacenter_id)
    server = datacenter.create_server(name: "server1", cores: 2, ram: 4096)

Create a composite server:

    volumes = [ { name: "server2-os", size: 10, image: "4dc4585c-505a-11e5-bfc6-52540066fee9", bus: "VIRTIO", imagePassword: "secretpassword" }, { name: "server2-data", size: 5, bus: "VIRTIO", licenceType: "UNKNOWN" } ]
    fwrules = [ { name: "SSH", protocol: "TCP", portRangeStart: 22, portRangeEnd: 22 } ]
    nics = [ { name: "public", lan: 1, firewallrules: fwrules }, { name: "private", lan: 2 } ]

    server = datacenter.create_server(name: "server2", cores: 1, ram: 1024, volumes: volumes, nics: nics)

Update a server:

    server.update(description: "My Server", cores: 4)

Remove a server:

    server.delete

Start a server:

    server.start

Stop a server:

    server.stop

Restart a server:

    server.reboot

## Server Volumes

List attached server volumes:

    server.list_volumes

Retrieve an attached volume:

    server.get_volume(volume_id)

Attach volume to a server:

    server.attach_volume(volume_id)

Detach volume from a server:

    server.detach_volume(volume_id)

## Server CD-ROMs

List attached CD-ROMs:

    server.list_cdroms

Retrieve attached CD-ROMs:

    server.get_cdrom(image_id)

Attach CD-ROM to a server:

    server.attach_cdrom(image_id)

Detach CD-ROM from a server:

    server.detach_cdrom(image_id)

# NIC

List all NICs:

    server = datacenter.get_server(server_id)
    server.list_nics

Retrieve a NIC:

    server = datacenter.get_server(server_id)
    server.get_nic(nic_id)

Create a NIC:

    server.create_nic(name: "nic1")

Update a NIC:

    nic = server.get_nic(nic_id)
    nic.update(name: "nic1_rename")

Remove NIC:

    nic = server.get_nic(nic_id)
    nic.delete

# Firewall Rule

List all NIC firewall rules:

    server = datacenter.get_server(server_id)
    nic = server.get_nic(nic_id)
    nic.list_firewall_rules

*Alias method*: ```nic.list_fwrules```

Retrieve a NIC firewall rule:

    server = datacenter.get_server(server_id)
    nic = server.get_nic(nic_id)
    fwrule = nic.get_firewall_rule(fwrule_id)

*Alias method*: ```nic.get_fwrule(fwrule_id)```

Create a firewall rule:

    fwrule = nic.create_firewall_rule(name: "OpenSSH port", protocol: "TCP", sourceMac: "01:23:45:67:89:00", portRangeStart: 22, portRangeEnd: 22)

*Alias method*: ```nic.create_fwrule(name: "OpenSSH port", ...)```

Update a firewall rule:

    fwrule.update(name: "SSH port")

Remove a firewall rule:

    fwrule.delete

# Volume

List all volumes within a datacenter:

    datacenter = Datacenter.get(datacenter_id)
    datacenter.list_volumes

Retrieve a volume:

    volume = datacenter.get_volume(volume_id)

Create a volume:

    volume = datacenter.create_volume(name: "volume1", size: 20)

Update a volume:

    volume.update(description: "My Volume", size: 40)

Remove a volume:

    volume.delete

Attach volume to a server:

    volume.attach(server_id)

Detach volume from a server:

    volume.detach

Create volume snapshot:

    volume.create_snapshot(name: "snapshot1", description: My Snapshot")

Restore a snapshot:

    volume.restore_snapshot(snapshot_id)

# Loadbalancer

List all loadbalancers within a datacenter:

    datacenter = Datacenter.get(datacenter_id)
    datacenter.list_loadbalancers

Retrieve a loadbalancer:

    lb = datacenter.get_loadbalancer(lb_id)

Create a loadbalancer:

    lb = datacenter.create_loadbalancer(name: “lb1”, …)

Update a loadbalancer:

    lb.update(name: “lb1_rename”)

Remove a loadbalancer:

    lb.delete

List all balanced NICs:

    lb.list_balanced_nics

*Alias method*: lb.list_nics

Associate NIC with a loadbalancer:

    lb.associate_balanced_nic(nic_id)

*Alias method*: lb.associate_nic(nic_id)

Retrieve a balanced NIC:

    lb.get_balanced_nic(nic_id)

*Alias method*: lb.get_nic(nic_id)

Remove a balanced NIC:

    lb = datacenter.get_loadbalancer(lb_id)
    balanced_nic = lb.get_balanced_nic(nic_id)
    balanced_nic.remove

# LAN

List all LANs:

    datacenter = Datacenter.get(datacenter_id)
    datacenter.list_lans

Retrieve a LAN:

    lan = datacenter.get_lan(lan_id)

Create a LAN:

    lan = datacenter.create_lan(name: "lan1", public: "true")

Update a LAN:

    lan.update(name: "lan1_rename")

Remove LAN:

    lan.delete

List LAN Members:

    lan.list_members

# Location

List all locations:

    Locations.list

Retrieve a location:

    Location.get(location_id)

# IP Block

List reserved IP blocks:

    IPBlock.list

Retrieve an IP block:

    ipblock = IPBlock.get(ipblock_id)

Reserve an IP block:

    ipblock = IPBlock.reserve(location: "us/las", size: 5)

Release an IP block:

    ipblock.release

# Image

List all images:

    Image.list

Retrieve an image:

    image = Image.get(image_id)

Update an image:

    image.update(name: "image1_rename")

Remove an image:

    image.delete

# Snapshot

List all snapshots:

    Snapshot.list

Retrieve a snapshot:

    snapshot = Snapshot.get(snapshot_id)

Update a snapshot:

    snapshot.update(name: "snapshot1_rename")

Remove a snapshot:

    snapshot.delete

# Request

List all requests:

    Request.list

Retrieve a request:

    request = Request.get(request_id)

Retrieve status of a request:

    request.status
