class nexus ( $nexus_base_dir, $version) {

$tarball="nexus-$version-bundle.tar.gz"
$nexus_install_dir="$nexus_base_dir/nexus-$version-bundle"

  file { $nexus_base_dir :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
  }
  
  exec {
    'download_nexus':
	command => "curl -O http://download.sonatype.com/nexus/oss/$tarball",
    cwd => "$nexus_base_dir",
    require => File[$nexus_base_dir],
    creates => "$nexus_base_dir/$tarball",
  }
  
  exec {
    'extract_nexus':
	command => "tar xf $tarball",
    cwd => "$nexus_base_dir",
    require => Exec['download_nexus'],
    creates => "$nexus_install_dir",
  }
  
  service { 'nexus':
    ensure     => running,
    hasstatus  => true,
    start      => "su ec2-user -c \"$nexus_install_dir/bin/linux-x86-64/nexus.sh start\"",
    stop       => "su ec2-user -c \"$nexus_install_dir/bin/linux-x86-64/nexus.sh stop\"",
	status     => "$nexus_install_dir/bin/linux-x86-64/nexus.sh status",
    require     => Exec [ 'extract_nexus' ]
  }
  
}
