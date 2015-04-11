include java
include git

class { 'stash' :
  stash_base_dir => '/opt/stash',
  version => '3.7.0',
  user => 'shazam',
  group => 'shaz',
}

cron { 'apply-puppet' :
  command => "/usr/bin/puppet apply /vagrant/puppet-scripts/stash/manifests/site.pp --modulepath=/vagrant/puppet-scripts/stash/modules",
  user    => root,
  minute  => 5
}

# need to disable so host can access guest machine
package { "firewalld":
  ensure => "purged",
}

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], logoutput => true, user => "vagrant" }
Package { allow_virtual => false }

Class ['java'] -> Class ['git'] -> Class ['stash']