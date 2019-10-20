# === Define selinux::fcontext ===
# Adds SELinux context definition for the specified path in current policy.
# It ensures that restorecon and new files creation apply correct context.
#
# === Parameters ===
# [*context*]
#   For example: samba_share_t
#
# [*path*]
# Absolute path to the file or directory.
#
define selinux::fcontext(
  String $context,
  Stdlib::Unixpath $path,
) {

  include selinux

  exec { "add_${context}_${path}":
    command   => "semanage fcontext -a -t ${context} \"${path}\"",
    path      => ['/usr/sbin', '/bin'],
    unless    => "semanage fcontext -l|grep \"^${path}.*:${context}:\"",
    require   => Package['policycoreutils-python'],
  }
}
