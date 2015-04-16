class java {
  package { 'java-1.7.0-openjdk-devel' :
    ensure => installed,
    provider => yum,
  }
}