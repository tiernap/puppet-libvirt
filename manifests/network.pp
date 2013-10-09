# Define libvirt::network
#
# define, configure, enable and autostart a network for libvirt guests
#
# Parameters:
#  $ensure
#    Ensure this network is defined (present), or enabled (running), or undefined (absent)
#  $autostart
#    Whether to start this network at boot time
#  $bridge
#    Name of the bridge this network will be attached to
#  $forward_mode
#    One of nat, route, bridge, vepa, passthrough, private, hostdev
#  $forward_dev
#    The interface to forward, useful in bridge and route mode
#  $forward_interfaces
#    An array of interfaces to forwad
#  $ip array hashes with
#    address
#    netmask (or alterntively prefix)
#    dhcp This is another hash that consists of
#      start - start of the range
#      end - end of the range
#      host - an array of hosts
#    bootp_file - A file to serve for servers booting from PXE
#    bootp_server - Which server that file is served from
#  $mac - A MAC for this network, if none is defined, libvirt will chose one for you
#
# Sample Usage :
#
# $dhcp = {
#   start      => '192.168.122.2',
#   end        => '192.168.122.254',
#   bootp_file => 'pxelinux.0',
# }
# $pxe_ip = {
#   'address' => '192.168.122.2'
#   'prefix'  => '24'
#   'dhcp'    => $dhcp,
# }
# libvirt::network { 'pxe':
#   ensure       => 'enabled',
#   autostart    => true,
#   forward_mode => 'nat',
#   ip           => [ $pxe_ip ],
# }
#
# libvirt::network { 'direct-net'
#   ensure             => 'enabled',
#   autostart          => true,
#   forward_mode       => 'bridge',
#   forward_dev        => 'eth0',
#   forward_interfaces => [ 'eth0', ],
# }
#
define libvirt::network (
  $ensure = 'present',
  $autostart = false,
  $bridge = undef,
  $forward_mode = undef,
  $forward_dev = undef,
  $forward_interfaces = [],
  $ip = undef,
  $mac = undef,
) {
  validate_bool ($autostart)
  validate_re ($ensure, '^(present|defined|enabled|running|undefined|absent)$',
    'Ensure must be one of defined (present), enabled (running), or undefined (absent).')

  case $ensure {
    'present', 'defined', 'enabled', 'running': {
      file { "/etc/libvirt/qemu/networks/${title}.xml":
        ensure  => present,
        content => template('libvirt/network.xml.erb')
      }
    }
    'undefined', 'absent': {
    }
    default: {
      notify { 'How did you even get here?':
        loglevel => 'crit',
      }
    }
  }
}

