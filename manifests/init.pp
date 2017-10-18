# === Class selinux ===
#
class selinux(
  Enum['enforcing','permissive','disabled'] $status = 'enforcing',
  Enum['targeted','minimum','mls']          $type   = 'targeted',
) {

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
    unless  => "getenforce | grep -i ${status}",
  }
}
