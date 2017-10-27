module Helpers
  def options
    {
      uuid: /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i,
      mac_addres: /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/,
        datacenter: {
          name: 'Ruby SDK Test',
          description: 'Ruby SDK test datacenter',
          location: 'us/las'
        },
        bad_datacenter: {
          name: 'Ruby SDK Datacenter',
        },

        datacenter_composite: {
          name: 'Ruby SDK Test Composite',
          description: 'Ruby SDK test composite datacenter',
          location: 'us/las',
          servers: [
            {
              name: 'Ruby SDK Test',
              ram: 1024,
              cores: 1
            }
          ],
          volumes: [
            {
              name: 'Ruby SDK Test',
              size: 2,
              bus: 'VIRTIO',
              type: 'HDD',
              licenceType: 'UNKNOWN',
              availabilityZone: 'ZONE_3'
            }
          ]
        },

        bad_id: '00000000-0000-0000-0000-000000000000',

        server: {
          name: 'Ruby SDK Test',
            ram: 1024,
            cores: 1,
            availabilityZone: 'ZONE_1',
            cpuFamily: 'INTEL_XEON'
        },

        bad_server: {
          name: 'New Server',
            ram: 1024,
        },

        volume: {
          name: 'Ruby SDK Test',
            size: 2,
            type: 'HDD',
            licenceType: 'UNKNOWN',
            availabilityZone: 'ZONE_3',
            bus: 'VIRTIO'
        },

        volume_with_alias: {
          name: 'volume created with alias',
            imagePassword: 'Vol44lias',
            size: 5,
            type: 'HDD',
            availabilityZone: 'AUTO',
            imageAlias: 'ubuntu:latest'
        },

        bad_volume: {
          name: 'bad volume to test failure ',
            size: 0,
            type: 'ABC',
            licenceType: 'UNKNOWN',
            availabilityZone: 'AUTO'
        },

        snapshot: {
          name: 'Ruby SDK Test',
          description: 'Ruby SDK test snapshot'
        },

        bad_snapshot: {
            description: 'description of a snapshot - updated'
        },


        nic: {
          name: 'Ruby SDK Test',
            dhcp: true,
            lan: 1,
            firewallActive: true,
            nat: false
        },

        bad_nic: {
          name: 'nic1',
            dhcp: true,
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

        bad_fwrule: {
          name: 'SSH',
            sourceMac: '01:23:45:67:89:00',
            sourceIp: nil,
            targetIp: nil,
            portRangeStart: 22,
            portRangeEnd: 22,
            icmpType: nil,
            icmpCode: nil
        },

        loadbalancer: {
          name: 'Ruby SDK Test',
            # ip: '10.2.2.3',
            dhcp: 'true'
        },

        bad_loadbalancer: {
            # ip: '10.2.2.3',
            #dhcp: 'true'
        },

        lan: {
          name: 'Ruby SDK Test',
          public: 'true'
        },

        bad_lan: {
            public: 'true'
        },

        ipblock: {
          name: 'Ruby SDK Test',
          location: 'us/las',
          size: 2
        },

        ipblock_failover: {
          location: 'us/las',
            size: 1
        },

        composite_server: {
          name: 'Ruby SDK Test Composite',
            ram: 1024,
            cores: 1,
            availabilityZone: 'ZONE_1',
            volumes: [
              {
                name: 'Ruby SDK Test',
                  size: 2,
                  type: 'HDD',
                  licenceType: 'UNKNOWN',
                  bus: 'VIRTIO',
                  availabilityZone: 'ZONE_3'
              }
            ],
            nics: [
              {
                name: 'Ruby SDK Test',
                  dhcp: 'true',
                  lan: 1,
                  firewallActive: true,
                  nat: false,
                  firewallrules: [
                    {
                        name: 'SSH',
                          protocol: 'TCP',
                          portRangeStart: 22,
                          portRangeEnd: 22,
                          sourceMac: '01:23:45:67:89:00'
                      }
                  ]
              }
            ]
        },
        group: {
          name: 'Ruby SDK Test',
          createDataCenter: true,
          createSnapshot: true,
          reserveIp: true,
          accessActivityLog: true
        },
        bad_group: {
          createDataCenter: true
        },
        share: {
          editPrivilege: true,
          sharePrivilege: true
        },
        user: {
          firstname: 'John',
          lastname: 'Doe',
          email: 'no-reply@example.com',
          password: 'secretpassword123',
          administrator: true,
          forceSecAuth: false
        },
        bad_user: {
          firstname: 'Jane',
          lastname: 'Doe'
        }
    }
  end

  def get_test_image(image_type)
    test_location = 'us/las'
    images = ProfitBricks::Image.list
    minImage = nil
    images.each do |image|
      if image.metadata['state'] == 'AVAILABLE' && image.properties['public'] == true && image.properties['imageType'] == image_type && image.properties['location'] == test_location && image.properties['licenceType'] == 'LINUX' && (minImage.nil? || minImage.properties.size > image.properties.size)
        minImage = image
      end
    end
    minImage
  end
end
