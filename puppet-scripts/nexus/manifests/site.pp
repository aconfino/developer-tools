include java

class { 'nexus' :
  nexus_base_dir => '/opt/nexus',
  version => '2.11.2-06',
}

# need to disable so host can access guest machine
package { "firewalld":
  ensure => "purged",
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], logoutput => true, user => "ec2-user" }
Package { allow_virtual => false }

Class ['java'] ->  Class ['nexus']
