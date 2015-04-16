class stash ( $stash_base_dir, $version){

$stash_home="$stash_base_dir/stash-home"
$stash_install_dir="$stash_base_dir/atlassian-stash-$version"
$tarball="atlassian-stash-$version.tar.gz"

  file { $stash_base_dir :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
  }
  
  file { $stash_home :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
	  require => File[$stash_base_dir],
  }

  exec {
    "download_stash":
	command => "curl -O https://downloads.atlassian.com/software/jira/downloads/$tarball",
    cwd => "$stash_base_dir",
    require => File[$stash_home],
    creates => "$stash_base_dir/$atlassian-stash-$version.tar.gz",
  }
  
  exec {
    'extract_stash':
	 cwd => $stash_base_dir,
     command => "tar xf $tarball",
	 user => "ec2-user",
	 creates => $stash_install_dir,
	 require => Exec['download_stash'],
  }

  exec { 
    "change_owners":
    command => "sudo chown $ec2-user:$ec2-user -R $stash_base_dir",
	cwd => "$stash_base_dir",
    require => Exec['extract_stash'],
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
