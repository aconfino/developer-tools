class bamboo ($bamboo_base_dir, $version){

$bamboo_home="$bamboo_base_dir/bamboo-home"
$bamboo_install_dir="$bamboo_base_dir/atlassian-bamboo-$version"
$tarball="atlassian-bamboo-$version.tar.gz"
 
   file { $bamboo_base_dir :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
  }
 
  file { $bamboo_home :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
	  require => File[$bamboo_base_dir],
  }
 
  exec {
    "download_bamboo":
	command => "curl -O https://downloads.atlassian.com/software/bamboo/downloads/$tarball",
    cwd => "$bamboo_base_dir",
    require => File[$bamboo_base_dir],
    creates => "$bamboo_base_dir/$tarball",
  }
  
  exec {
    'extract_bamboo':
	 cwd => $bamboo_base_dir,
     command => "tar xf $tarball",
	 user => "ec2-user",
	 creates => $bamboo_install_dir,
	 require => Exec['download_bamboo'],
  }
  
   exec { 
    "change_owners":
    command => "chown ec2-user:ec2-user -R $bamboo_base_dir",
	cwd => "$bamboo_base_dir",
    require => Exec["extract_bamboo"],
	notify => Service["bamboo"]
  }
 
  file { "/etc/environment":
    content => inline_template("BAMBOO_HOME=$bamboo_home"),
  }

  service { 'bamboo':
    ensure     => running,
    hasstatus  => false,
    start      => "su ec2-user -c $bamboo_install_dir/bin/start-bamboo.sh",
    stop       => "su ec2-user -c $bamboo_install_dir/bin/stop-bamboo.sh",
	status     => "puppet:///modules/bamboo/bamboo-status.sh",
    require    => [ File["/etc/environment"], 
					Exec[ "change_owners" ] 
					]
  }
 
}
