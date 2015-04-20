module Helpers
  def options
    {
      datacenter: {
        name: 'My New Datacenter',
        description: 'Production environment',
        location: 'de/fkb'
      },

      server: {
        name: 'New Server',
        ram: 1024,
        cores: 1
      },

      volume: {
        name: 'my boot volume for server 1',
        size: 10,
        licenceType: 'UNKNOWN'
      },

      snapshot: {
        name: 'Snapshot of storage X on 12.12.12 12:12:12 - updated',
        description: 'description of a snapshot - updated'
      },

      nic: {
        name: 'nic1',
        # ips: [ '10.1.1.1' ],
        dhcp: 'true',
        lan: 1,
        firewallActive: true
      },

      fwrule: {
        name: 'Open SSH port',
        protocol: 'TCP',
        sourceMac: '01:23:45:67:89:00',
        sourceIp: nil,
        targetIp: nil,
        portRangeStart: 22,
        portRangeEnd: 22,
        icmpType: nil,
        icmpCode: nil
      },

      loadbalancer: {
        name: 'My LB',
        # ip: '10.2.2.3',
        dhcp: 'true'
      },

      lan: {
        name: 'public Lan 4',
        public: 'true'
      },

      ipblock: {
        location: "de/fra",
        size: 1
      }
    }
  end
end
