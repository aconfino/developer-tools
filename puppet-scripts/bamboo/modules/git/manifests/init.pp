class git {
  package { 'git.x86_64' :
    ensure => installed,
    provider => yum,
  }
}