include java
include unzip

class { 'sonar' :
  stash_base_dir => '/opt/sonar',
  version => '5.1',
}

# need to disable so host can access guest machine
package { "firewalld":
  ensure => "purged",
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], logoutput => true, user => "ec2-user" }
Package { allow_virtual => false }

Class ['java'] -> Class ['git'] -> Class ['stash']