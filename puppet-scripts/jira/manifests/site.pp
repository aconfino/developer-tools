include java

class { 'jira' :
  jira_base_dir => '/opt/jira',
  version => '6.3.14',
  user => 'shazam',
  group => 'shaz',
}

cron { 'apply-puppet' :
  command => "/usr/bin/puppet apply /vagrant/puppet-scripts/jira/manifests/site.pp --modulepath=/vagrant/puppet-scripts/jira/modules",
  user    => root,
  minute  => 5
}

# need to disable so host can access guest machine
package { "firewalld":
  ensure => "purged",
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], logoutput => true, user => "vagrant" }
Package { allow_virtual => false }

Class ['java'] -> Class ['jira']