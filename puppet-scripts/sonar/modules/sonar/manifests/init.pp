class sonar ( $sonar_base_dir, $version) {

$sonar_install_dir="$sonar_base_dir/sonarqube-$version"
$zip="sonarqube-$version.zip"

  file { $sonar_base_dir :
      ensure => directory,
	  owner => "ec2-user",
	  group => "ec2-user",
  }
  
  exec {
    'download_sonar':
	command => "curl -O http://dist.sonar.codehaus.org/$zip",
    cwd => "$sonar_base_dir",
    require => File[$sonar_base_dir],
    creates => "$sonar_base_dir/$zip",
  }
  
  exec {
    "extract_sonar":
	command => "unzip $zip",
    cwd => "$sonar_base_dir",
    require => Exec['download_sonar'],
    creates => "$sonar_install_dir",
  }
  
  
  
}
