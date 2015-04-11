include java

class { 'jira' :
  jira_base_dir => '/opt/jira',
  version => '6.3.14',
}

# need to disable so host can access guest machine
package { "firewalld":
  ensure => "purged",
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], logoutput => true, user => "ec2-user" }
Package { allow_virtual => false }

Class ['java'] -> Class ['jira']