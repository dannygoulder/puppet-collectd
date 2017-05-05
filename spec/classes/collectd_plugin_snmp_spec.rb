require 'spec_helper'

describe 'collectd::plugin::snmp', type: :class do
  let :facts do
    {
      osfamily: 'RedHat',
      collectd_version: '4.8.0',
      operatingsystemmajrelease: '7',
      python_dir: '/usr/local/lib/python2.7/dist-packages'
    }
  end

  let :pre_condition do
    'include ::collectd'
  end

  context ':ensure => present and dataset for AMAVIS-MIB::inMsgs.0' do
    let :params do
      {
        data: {
          'amavis_incoming_messages' => {
            'type'     => 'counter',
            'table'    => false,
            'instance' => 'amavis.inMsgs',
            'values'   => ['AMAVIS-MIB::inMsgs.0']
          }
        },
        hosts: {
          'scan04' => {
            'address'   => '127.0.0.1',
            'version'   => 2,
            'community' => 'public',
            'collect'   => ['amavis_incoming_messages'],
            'interval'  => 10
          }
        }
      }
    end

    it 'Will create /etc/collectd.d/10-snmp.conf' do
      is_expected.to contain_file('snmp.load').with(ensure: 'present',
                                                    path: '/etc/collectd.d/10-snmp.conf',
                                                    content: %r{Data "amavis_incoming_messages".+Instance "amavis.inMsgs".+Host "scan04".+Community "public"}m)
    end
  end

  context ':ensure => absent' do
    let :params do
      {
        ensure: 'absent',
        data: {
          'amavis_incoming_messages' => {
            'type'     => 'counter',
            'table'    => false,
            'instance' => 'amavis.inMsgs',
            'values'   => ['AMAVIS-MIB::inMsgs.0']
          }
        },
        hosts: {
          'scan04' => {
            'address'   => '127.0.0.1',
            'version'   => 2,
            'community' => 'public',
            'collect'   => ['amavis_incoming_messages'],
            'interval'  => 10
          }
        }
      }
    end

    it 'Will not create /etc/collectd.d/10-snmp.conf' do
      is_expected.to contain_file('snmp.load').with(ensure: 'absent',
                                                    path: '/etc/collectd.d/10-snmp.conf')
    end
  end

  context 'SNMPv3' do
    let :params do
      {
        data: {
          'hc_octets' => {
            'type'     => 'if_octets',
            'table'    => true,
            'instance' => 'IF-MIB::ifName',
            'values'   => ['IF-MIB::ifHCInOctets', 'IF-MIB::ifHCOutOctets'],
          },
        },
        hosts: {
          'router' => {
            'address'            => '192.0.2.1',
            'version'            => 3,
            'username'           => 'collectd',
            'security_level'     => 'authPriv',
            'auth_protocol'      => 'SHA',
            'auth_passphrase'    => 'mekmitasdigoat',
            'privacy_protocol'   => 'AES',
            'privacy_passphrase' => 'mekmitasdigoat',
            'collect'            => ['hc_octets'],
            'interval'           => 30,
          },
        },
      }
    end

    it 'Will create /etc/collectd.d/10-snmp.conf' do
      is_expected.to contain_file('snmp.load').with(ensure: 'present',
                                                    path: '/etc/collectd.d/10-snmp.conf',
                                                    content: %r{Data "hc_octets".+Instance "IF-MIB::ifName".+Host "router".+Username "collectd".+SecurityLevel "authPriv".+AuthProtocol "SHA".+PrivacyProtocol "AES"}m)
    end
  end
end
