class jira ( $jira_base_dir, $version, $user, $group ){

$jira_home="$jira_base_dir/jira-home"
$jira_install_dir="$jira_base_dir/atlassian-jira-$version-standalone"
 
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
    "create_jira_home":
    command => "sudo mkdir -p $jira_home",
    creates => "$jira_home",
	require => User["$user"],
  }

  exec {
    "download_jira":
	command => "curl -L https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-$version.tar.gz | sudo tar zx",
    cwd => "$jira_base_dir",
    require => Exec["create_jira_home"],
    creates => "$jira_install_dir",
  }
  
   exec { 
    "change_owners":
    command => "sudo chown $user:$group -R $jira_base_dir",
	cwd => "$jira_base_dir",
    require => Exec["download_jira"],
	notify => Service["jira"]
  }
  
  file { "/etc/profile.d/jira-setup.sh":
    content => inline_template("export JIRA_HOME=$jira_home"),
  }
  
  service { 'jira':
    ensure     => running,
    hasstatus  => true,
    start      => "/vagrant/puppet-scripts/safe-start.sh $jira_home $user $jira_install_dir/bin/start-jira.sh",
    stop       => "sudo su - $user -c $jira_install_dir/bin/stop-jira.sh",
    require     => File["/etc/profile.d/jira-setup.sh"],
  }
 
}
