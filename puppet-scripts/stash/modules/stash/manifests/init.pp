class stash ( $stash_base_dir, $version){

$stash_home="$stash_base_dir/stash-home"
$stash_install_dir="$stash_base_dir/atlassian-stash-$version"
$tarball="atlassian-stash-$version.tar.gz"
$environment_properties="$stash_install_dir/bin/setenv.sh"

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
	command => "curl -O https://downloads.atlassian.com/software/stash/downloads/$tarball",
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
    command => "chown ec2-user:ec2-user -R $stash_base_dir",
	cwd => "$stash_base_dir",
    require => Exec['extract_stash'],
  }
  
  file_line { 'modify STASH_HOME variable':
    path => $environment_properties,  
    line => "export STASH_HOME==$stash_home",
    match   => "export STASH_HOME=",
	require => Exec["change_owners"],
  }
  
  file_line { 'modify JVM_MINIMUM_MEMORY':
    path => $environment_properties,  
    line => "JVM_MINIMUM_MEMORY=\"768m\"",
    match   => "JVM_MINIMUM_MEMORY=\"512m\"",
	require => Exec["change_owners"],
  }
  
  file_line { 'modify JVM_MAXIMUM_MEMORY':
    path => $environment_properties,  
    line => "JVM_MAXIMUM_MEMORY=\"1536m\"",
    match   => "JVM_MAXIMUM_MEMORY=\"768m\"",
	require => Exec["change_owners"],
  }
  
  service { 'stash':
    ensure     => running,
    hasstatus  => true,
    start      => "su ec2-user -c $stash_install_dir/bin/start-stash.sh",
    stop       => "su ec2-user -c $stash_install_dir/bin/stop-stash.sh",
	status     => "puppet:///modules/stash/stash-status.sh",
    require     => [ File_line [ 'modify STASH_HOME variable' ],
					 File_line [ 'modify JVM_MINIMUM_MEMORY' ],
					 File_line [ 'modify JVM_MAXIMUM_MEMORY' ]
					]
  }
 
 
}
