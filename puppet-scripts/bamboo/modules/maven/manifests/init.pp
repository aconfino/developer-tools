class maven {
  
  $maven_root="/usr/local/apache-maven"
  $maven_home="$maven_root/apache-maven-3.2.5"
  
  
  file { $maven_root :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
  }
  
  exec {
    'download_maven':
	 cwd => $maven_root,
     command => 'curl -O http://mirror.nexcess.net/apache/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz',
	 user => "ec2-user",
	 creates => "$maven_root/apache-maven-3.2.5-bin.tar.gz",
	 require => File[$maven_root],
  }
  
  exec {
    'extract_maven':
	 cwd => $maven_root,
     command => 'tar xf apache-maven-3.2.5-bin.tar.gz',
	 user => "ec2-user",
	 creates => $maven_home,
	 require => Exec['download_maven'],
  }
  
  file { '/etc/profile.d/maven-setup.sh':
      source => 'puppet:///modules/maven/maven-setup.sh',
      mode => '755',
  }
  
}