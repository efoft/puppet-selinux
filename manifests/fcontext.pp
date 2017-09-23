#
define selinux::fcontext(
  $context    = undef,
  $path       = undef
) {

  if ! $context or ! $path {
    fail('Parameters context and path are required.')
  }
  
  ensure_packages('policycoreutils-python', {'ensure' => 'installed'})

  exec { "add_${context}_${path}":
    command   => "semanage fcontext -a -t ${context} \"${path}\"",
    path      => ['/usr/sbin', '/bin'],
    unless    => "semanage fcontext -l|grep \"^${path}.*:${context}:\"",
    require   => Package['policycoreutils-python'],
  }
}
