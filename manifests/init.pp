#
class selinux(
  $status = 'enforcing',
  $type   = 'targeted',
) {

  validate_re($status, ['enforcing','permissive','disabled'], "${status} is not valid for status, expected values are: 'enforcing','permissive','disabled'")
  validate_re($type, ['targeted','minimum','mls'], "${type} is not valid for status, expected values are: 'targeted','minimum','mls'")

  file_line { "selinux-${status}":
    path  => '/etc/selinux/config',
    line  => "SELINUX=${status}",
    match => '^SELINUX=',
  }

  file_line { "selinux-${type}":
    path  => '/etc/selinux/config',
    line  => "SELINUXTYPE=${type}",
    match => '^SELINUXTYPE=',
  }

  ensure_packages('policycoreutils-python', {'ensure' => 'latest'})

  exec { 'selinux-setenforce':
    command => $status ? { 'enforcing' => 'setenforce 1', 'permissive' => 'setenforce 0' },
    path    => ['/usr/sbin','/sbin','/usr/bin','/bin'],
    onlyif  => 'getenforce | grep -i permissive',
  }
}
