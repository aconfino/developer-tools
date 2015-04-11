class stash ( $stash_base_dir, $version){

$stash_home="$stash_base_dir/stash-home"
$stash_install_dir="$stash_base_dir/atlassian-stash-$version"

  exec {
    "create_stash_home":
    command => "sudo mkdir -p $stash_home",
    creates => "$stash_home",
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
    command => "sudo chown $ec2-user:$ec2-user -R $stash_base_dir",
	cwd => "$stash_base_dir",
    require => Exec["download_stash"],
	notify => Service["stash"]
  }
  
  file { "/etc/profile.d/stash-setup.sh":
    content => inline_template("export STASH_HOME=$stash_home"),
  }
 
  ## TODO need to be updated
  service { 'stash':
    ensure     => running,
    hasstatus  => true,
    start      => "/vagrant/puppet-scripts/safe-start.sh $stash_home $user $stash_install_dir/bin/start-stash.sh",
    stop       => "sudo su - $user -c $stash_install_dir/bin/stop-stash.sh",
    require     => File["/etc/profile.d/stash-setup.sh"],
  }
 
}
