class jira ( $jira_base_dir, $version){

$jira_home="$jira_base_dir/jira-home"
$jira_install_dir="$jira_base_dir/atlassian-jira-$version-standalone"
$tarball="atlassian-jira-$version.tar.gz"
$jira_properties="$jira_install_dir/atlassian-jira/WEB-INF/classes/jira-application.properties"
$environment_properties="$jira_install_dir/bin/setenv.sh"

  file { $jira_base_dir :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
  }
  
  file { $jira_home :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
	  require => File[$jira_base_dir],
  }

  exec {
    "download_jira":
	command => "curl -O https://downloads.atlassian.com/software/jira/downloads/$tarball",
    cwd => "$jira_base_dir",
    require => File[$jira_home],
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
    command => "chown ec2-user:ec2-user -R $jira_base_dir",
	cwd => "$jira_base_dir",
    require => Exec["download_jira"],
	notify => Service["jira"]
  }
  
  file_line { 'modify JIRA_HOME variable':
    path => $jira_properties,  
    line => "jira.home=$jira_home",
    match   => "jira.home =",
  }
  
  file_line { 'modify JVM_MINIMUM_MEMORY':
    path => $environment_properties,  
    line => "JVM_MINIMUM_MEMORY=\"768m\"",
    match   => "JVM_MINIMUM_MEMORY=\"384m\"",
  }
  
  file_line { 'modify JVM_MAXIMUM_MEMORY':
    path => $environment_properties,  
    line => "JVM_MAXIMUM_MEMORY=\"768m\"",
    match   => "JVM_MAXIMUM_MEMORY=\"1536m\"",
  }
  
  service { 'jira':
    ensure     => running,
    hasstatus  => true,
    start      => "su ec2-user -c $jira_install_dir/bin/start-jira.sh",
    stop       => "su ec2-user -c $jira_install_dir/bin/stop-jira.sh",
	status     => "puppet:///modules/jira/jira-status.sh",
    require     => [ File_line [ 'modify JIRA_HOME variable' ],
					 File_line [ 'modify JVM_MINIMUM_MEMORY' ],
					 File_line [ 'modify JVM_MAXIMUM_MEMORY' ]
					]
  }
 
}
