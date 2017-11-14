# === Define selinux::audit2allow ===
# Build custom policy modile from avc-messages and installs the module.
#
# === Parameters ===
# [*avc_msg*]
# Messages from audit.log to use to build policy module.
#
# [*avc_file*]
# Instead of *avc_msg* the file can be specified containing avc-denial messages from audit log.
#
# [*workdir*]
# Where to put source messages file, .te and .pp files.
#
# [*semodule_name*]
# It is auto-generated but can be customized. They start with 'local_fix' prefix in order not
# to conflict with any other modules.
#
#
define selinux::audit2allow (
  Optional[String] $avc_msg       = undef,
  Optional[String] $avc_file      = undef,
  String $workdir                 = '/usr/share/selinux/local',
  Optional[String] $semodule_name = undef,
) {

  if ! $avc_msg and ! $avc_file {
    fail('Either avc_file or avc_msg parameter must be set.')
  }
  if $avc_msg and $avc_file {
    file('Only one of avc_msg or avc_file must be set.')
  }

  ensure_resource('file', $workdir, { 'ensure' => 'directory' })

  $_title        = regsubst(downcase($title), '[\s-]','_','G')
  $avcfile  = "${workdir}/avc_${_title}.txt"
  $semodule = pick($semodule_name, "local_fix_${_title}")

  file { $avcfile:
    ensure  => file,
    content => $avc_msg,
    source  => $avc_file,
    require => File[$workdir],
    notify  => Exec["build-policy-module-${semodule}"],
  }

  exec { "build-policy-module-${semodule}":
    command     => "audit2allow -i ${avcfile} -M ${semodule}",
    cwd         => $workdir,
    path        => ['/usr/bin'],
    refreshonly => true,
    notify      => Exec["install-policy-module-${semodule}"],
  }

  exec { "install-policy-module-${semodule}":
    command     => "semodule -i ${workdir}/${semodule}.pp",
    path        => '/usr/sbin',
    refreshonly => true,
  }
}
