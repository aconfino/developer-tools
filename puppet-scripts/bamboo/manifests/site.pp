include java
include maven
include git

class { 'bamboo' :
  bamboo_base_dir => '/opt/bamboo',
  version => '5.8.1'
}

# need to disable so host can access guest machine
package { "firewalld":
  ensure => "purged",
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], user => "ec2-user", logoutput => true, }
Package { allow_virtual => false }

Class ['java'] -> Class ['maven'] -> Class ['git'] -> Class ['bamboo']
