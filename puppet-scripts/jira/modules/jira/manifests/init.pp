class jira ( $jira_base_dir, $version){

$jira_home="$jira_base_dir/jira-home"
$jira_install_dir="$jira_base_dir/atlassian-jira-$version-standalone"
$tarball=atlassian-jira-$version.tar.gz

  file { $bamboo_base_dir :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
  }

  exec {
    "create_jira_home":
    command => "sudo mkdir -p $jira_home",
    creates => "$jira_home",
  }

  exec {
    "download_jira":
	command => "curl -O https://downloads.atlassian.com/software/jira/downloads/$tarball",
    cwd => "$jira_base_dir",
    require => Exec["create_jira_home"],
    creates => "$jira_install_dir",
  }
  
  exec {
    'extract_jira':
	 cwd => $jira_base_dir,
     command => "tar xf $tarball",
	 user => "ec2-user",
	 creates => $jira_install_dir,
	 require => Exec['download_jira'],
  }
  
   exec { 
    "change_owners":
    command => "sudo chown ec2-user:ec2-user -R $jira_base_dir",
	cwd => "$jira_base_dir",
    require => Exec["download_jira"],
	notify => Service["jira"]
  }
  
  file { "/etc/profile.d/jira-setup.sh":
    content => inline_template("export JIRA_HOME=$jira_home"),
  }
  
  ## TODO fix this
  service { 'jira':
    ensure     => running,
    hasstatus  => true,
    start      => "/vagrant/puppet-scripts/safe-start.sh $jira_home $user $jira_install_dir/bin/start-jira.sh",
    stop       => "sudo su - $user -c $jira_install_dir/bin/stop-jira.sh",
    require     => File["/etc/profile.d/jira-setup.sh"],
  }
 
}
