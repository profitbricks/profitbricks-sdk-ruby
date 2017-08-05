module Helpers
  def options
    {
        uuid: /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i,
        datacenter: {
            name: 'Ruby SDK Datacenter',
            description: 'SDK test environment',
            location: 'de/fkb'
        },

        datacenter_composite: {
            name: 'Ruby SDK Composite Datacenter',
            description: 'SDK  Composite test environment',
            location: 'de/fkb',
            servers: [
                {
                    name: 'New Composite Server',
                    ram: 1024,
                    cores: 1,
                    volumes: [
                        {
                            name: 'composite-boot',
                            size: 5,
                            type: 'HDD',
                            licenceType: 'UNKNOWN'
                        }
                    ]
                }
            ]
        },

        server: {
            name: 'New Server',
            ram: 1024,
            cores: 1
        },

        volume: {
            name: 'my boot volume for server 1',
            size: 5,
            type: 'HDD',
            licenceType: 'UNKNOWN',
            availabilityZone: 'AUTO'
        },

        bad_volume: {
            name: 'bad volume to test failure ',
            size: 0,
            type: 'ABC',
            licenceType: 'UNKNOWN',
            availabilityZone: 'AUTO'
        },

        snapshot: {
            name: 'Snapshot of storage X on 12.12.12 12:12:12 - updated',
            description: 'description of a snapshot - updated'
        },

        nic: {
            name: 'nic1',
            dhcp: true,
            lan: 1,
            firewallActive: true,
            nat: false
        },

        fwrule: {
            name: 'SSH',
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
        },

        composite_server: {
            name: 'New Composite Server',
            ram: 1024,
            cores: 1,
            volumes: [
                {
                    name: 'composite-boot',
                    size: 5,
                    type: 'HDD',
                    licenceType: 'UNKNOWN'
                }
            ],
            nics: [
                {
                    name: 'nic1',
                    dhcp: 'true',
                    lan: 1,
                    firewallrules: [
                        {
                            name: 'SSH',
                            protocol: 'TCP',
                            portRangeStart: 22,
                            portRangeEnd: 22,
                        }
                    ]
                }
            ]
        }
    }
  end



  def get_test_image(image_type)
    test_location= 'de/fkb'
    images = ProfitBricks::Image.list
    minImage = nil
    images.each do |image|
      if image.metadata['state']=='AVAILABLE' && image.properties['public']==true &&image.properties['imageType']==image_type &&image.properties['location']==test_location && image.properties['licenceType']=='LINUX' && (minImage == nil || minImage.properties.size > image.properties.size)
        minImage=image
      end
    end
    minImage
  end
end
