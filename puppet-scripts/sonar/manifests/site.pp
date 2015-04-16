include java

class { 'sonar' :
  sonar_base_dir => '/opt/sonar',
  version => '5.1',
}

# need to disable so host can access guest machine
package { "firewalld":
  ensure => "purged",
}

package { 'unzip-6.0-15.el7.x86_64' :
   ensure => installed,
   provider => yum,
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], logoutput => true, user => "ec2-user" }
Package { allow_virtual => false }

Class ['java'] ->  Class ['sonar']
