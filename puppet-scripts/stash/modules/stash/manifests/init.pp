class stash ( $stash_base_dir, $version, $user, $group ){

$stash_home="$stash_base_dir/stash-home"
$stash_install_dir="$stash_base_dir/atlassian-stash-$version"

  group { "$group" :
    ensure => present,
    gid => 501,
  }

  user {
    "$user":
     uid => '3000',
     groups => "$group",
     home => "/home/$user",
     ensure => present,
     managehome => true,
	 require => Group["$group"],
  }

  exec {
    "create_stash_home":
    command => "sudo mkdir -p $stash_home",
    creates => "$stash_home",
	require => User["$user"],
  }

  exec {
    "download_stash":
	command => "curl -L http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-$version.tar.gz | sudo tar zx",
    cwd => "$stash_base_dir",
    require => Exec["create_stash_home"],
    creates => "$stash_install_dir",
  }
  
   exec { 
    "change_owners":
    command => "sudo chown $user:$group -R $stash_base_dir",
	cwd => "$stash_base_dir",
    require => Exec["download_stash"],
	notify => Service["stash"]
  }
  
  file { "/etc/profile.d/stash-setup.sh":
    content => inline_template("export STASH_HOME=$stash_home"),
  }
 
  service { 'stash':
    ensure     => running,
    hasstatus  => true,
    start      => "/vagrant/puppet-scripts/safe-start.sh $stash_home $user $stash_install_dir/bin/start-stash.sh",
    stop       => "sudo su - $user -c $stash_install_dir/bin/stop-stash.sh",
    require     => File["/etc/profile.d/stash-setup.sh"],
  }
 
}
