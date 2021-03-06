#! @shell@

# - make Nix store etc.
# - copy closure of Nix to target device
# - register validity
# - with a chroot to the target device:
#   * nix-env -p /nix/var/nix/profiles/system -i <nix-expr for the configuration>
#   * install the boot loader

# Ensure a consistent umask.
umask 0022

# Create FHS for Triton relative to mountpoint ($1).
create_triton_fhs() {
  local -a -r directories=(
    'bin'  # /bin/sh
    'dev'
    'etc'
    'etc/ssl'
    'etc/ssl/certs'
    'home'
    'media'
    'mnt'
    'nix'
    'nix/store'
    'nix/var'
    'nix/var/log'
    'nix/var/log/nix'
    'nix/var/log/nix/drvs'
    'nix/var/nix'
    'nix/var/nix/db'
    'nix/var/nix/gcroots'
    'nix/var/nix/manifests'
    'nix/var/nix/profiles'
    'nix/var/nix/profiles/per-user'
    'nix/var/nix/profiles/per-user/root'
    'nix/var/nix/temproots'
    'nix/var/userpool'
    'proc'
    'root'
    'root/.nix-defexpr'
    'run'
    'sys'
    'tmp'
    'tmp/root'
    'usr'
    'usr/bin'  # /usr/bin/env
    'var'
    'var/setuid-wrappers'
  )
  # BASH associative arrays are ordered by hash, so this is only
  # used as a lookup for the directory's permissions.
  local -A -r directory_permissions=(
    ['bin']='0755'  # /bin/sh
    ['dev']='0755'
    ['etc']='0755'
    ['etc/ssl']='0755'
    ['etc/ssl/certs']='0755'
    ['home']='0755'
    ['media']='0755'
    ['mnt']='0755'
    ['nix']='0755'
    ['nix/store']='1775'
    ['nix/var']='0755'
    ['nix/var/log']='0755'
    ['nix/var/log/nix']='0755'
    ['nix/var/log/nix/drvs']='0755'
    ['nix/var/nix']='0755'
    ['nix/var/nix/db']='0755'
    ['nix/var/nix/gcroots']='0755'
    ['nix/var/nix/manifests']='0755'
    ['nix/var/nix/profiles']='0755'
    ['nix/var/nix/profiles/per-user']='1777'
    ['nix/var/nix/profiles/per-user/root']='0755'
    ['nix/var/nix/temproots']='0755'
    ['nix/var/userpool']='0755'
    ['proc']='0755'
    ['root']='0700'
    ['root/.nix-defexpr']='0700'
    ['run']='0755'
    ['sys']='0755'
    ['tmp']='01777'
    ['tmp/root']='0755'
    ['usr']='0755'
    ['usr/bin']='0755'  # /usr/bin/env
    ['var']='0755'
    ['var/setuid-wrappers']='0755'
  )
  local directory
  local -r mount_point="${1}"

  # Create directory structure relative to $mount_point.
  for directory in "${directories[@]}"; do
    if [ -d "${mount_point}/${directory}" ]; then
      chmod --verbose "${directory_permissions["${directory}"]}" \
        "${mount_point}/${directory}" || {
          echo "ERROR: failed to set permissions for directory: ${mount_point}/${directory}" >&2
          return 1
        }
    else
      # Do NOT specify --parents to make sure the directory structure is
      # unrolled correctly.  Instead specify the parent directories in
      # the array above so that the structure is created with the correct
      # permissions.
      mkdir \
        --verbose \
        --mode="${directory_permissions["${directory}"]}" \
        "${mount_point}/${directory}" || {
          echo "ERROR: failed to create directory: ${mount_point}/${directory}" >&2
          return 1
        }
    fi
  done
}

copy_host_file() {
  local -r destination_file="${3}"
  local file
  local -r mount_point="${1}"
  local -r permissions="${2}"
  shift 3
  local -a source_files=("$@")

  if [ -f "${mount_point}/${destination_file}" ]; then
    rm --force --verbose "${mount_point}/${destination_file}"
  fi

  # Always assume destination location is a source
  source_files+=("${destination_file}")

  for file in "${source_files[@]}"; do
    if [ -f "/${file}" ]; then
      cp --dereference --force --verbose "/${file}" \
        "${mount_point}/${destination_file}"
      chmod "${permissions}" "${mount_point}/${destination_file}"
      break
    fi
  done
}

rbind_host_dir() {
  local -r destination_dir="${2}"
  local dir
  local -r mount_point="${1}"
  shift 2
  local -a source_dirs=("$@")

  # Always assume destination location is a source
  source_dirs+=("${destination_dir}")

  for dir in "${source_dirs[@]}"; do
    if [ -d "/${dir}" ]; then
      mount ${debugFlags:+--verbose} --rbind "/${dir}" \
        "${mount_point}/${destination_dir}"
      break
    fi
  done

  # Track created rbind mounts
  TRACK_MOUNTS+=("${mount_point}/${destination_dir}")
}

rbind_host_file() {
  local -r destination_file="${2}"
  local file
  local -r mount_point="${1}"
  shift 2
  local -a source_files=("$@")

  if [ -f "${mount_point}/${destination_file}" ]; then
    rm --force --verbose "${mount_point}/${destination_file}"
  fi

  # Always assume destination location is a source
  source_files+=("${destination_file}")

  for file in "${source_files[@]}"; do
    if [ -f "/${file}" ]; then
      touch "${mount_point}/${destination_file}"
      mount ${debugFlags:+--verbose} --rbind --options ro "/${file}" \
        "${mount_point}/${destination_file}"
      break
    fi
  done

  # Track created rbind mounts
  TRACK_MOUNTS+=("${mount_point}/${destination_file}")
}

cleanup_mounts() {
  local index
  local rbind

  # Un-mount in the reverse order they were mounted
  for ((index=${#TRACK_MOUNTS[@]}-1; index>=0; index--)) ; do
    umount ${debugFlags:+--verbose} "${TRACK_MOUNTS["${index}"]}"
  done
}

error_trace() {
  local -i i=0
  local -i x=${#BASH_LINENO[@]}

  for ((i=x-2; i>=0; i--)); do
    echo '  File' \"${BASH_SOURCE[i+1]}\", line ${BASH_LINENO[i]}, in ${FUNCNAME[i+1]}
    # Print the text from the line
    sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i+1]}"
  done
}

# Re-exec ourselves in a private mount namespace so that our bind
# mounts get cleaned up automatically.
if [ $(id -u) -eq 0 ]; then
  if [ -z "$NIXOS_INSTALL_REEXEC" ]; then
    export NIXOS_INSTALL_REEXEC=1
    exec unshare --mount --uts -- "$0" "$@"
  else
    mount ${debugFlags:+--verbose} --make-rprivate '/'
  fi
fi

# Parse the command line for the -I flag
extraBuildFlags=()
chrootCommand=('/run/current-system/sw/bin/bash')
buildUsersGroup='nixbld'

while [ "$#" -gt 0 ]; do
  i="$1"; shift 1
  case "$i" in
    '--max-jobs'|'-j'|'--cores'|'-I')
      j="$1"; shift 1
      extraBuildFlags+=("$i" "$j")
      ;;
    '--option')
      j="$1"; shift 1
      k="$1"; shift 1
      extraBuildFlags+=("$i" "$j" "$k")
      ;;
    '--root')
      MOUNT_POINT="$1"; shift 1
      ;;
    '--closure')
      closure="$1"; shift 1
      buildUsersGroup=""
      ;;
    '--no-channel-copy')
      noChannelCopy=1
      ;;
    '--no-root-passwd')
      noRootPasswd=1
      ;;
    '--no-bootloader')
      noBootLoader=1
      ;;
    '--show-trace')
      extraBuildFlags+=("$i")
      ;;
    '--chroot')
      runChroot=1
      if [ ! -z "$@" ]; then
        chrootCommand=("$@")
      fi
      break
      ;;
    '--debug')
      debugFlags=1
      ;;
    '--help')
      exec man nixos-install
      exit 1
      ;;
    *)
      echo "$0: unknown option \`$i'" >&2
      exit 1
      ;;
  esac
done

set -o errexit
set -o errtrace
set -o functrace
set -o pipefail
shopt -s nullglob

trap 'error_trace; exit 1' ERR

declare -r MOUNT_POINT="${MOUNT_POINT:-/mnt}"
if [ ! -e "$MOUNT_POINT" ]; then
  echo "mount point doesn't exist: $MOUNT_POINT" >&2
  exit 1
fi

declare NIXOS_CONFIG="${NIXOS_CONFIG:-/etc/nixos/configuration.nix}"
if [ ! -e "$MOUNT_POINT/$NIXOS_CONFIG" ]; then
  echo "nixos config doesn't exist: $MOUNT_POINT/$NIXOS_CONFIG" >&2
  exit 1
fi

declare -a TRACK_MOUNTS

create_triton_fhs "${MOUNT_POINT}"

copy_host_file "${MOUNT_POINT}" '0644' 'etc/hosts'
copy_host_file "${MOUNT_POINT}" '0644' 'etc/resolv.conf'
copy_host_file "${MOUNT_POINT}" '0644' 'etc/ssl/certs/ca-certificates.crt' \
  'etc/ssl/certs/ca-bundle.crt'

rbind_host_file "${MOUNT_POINT}" 'etc/group'
rbind_host_file "${MOUNT_POINT}" 'etc/passwd'

rbind_host_dir "${MOUNT_POINT}" 'dev'
rbind_host_dir "${MOUNT_POINT}" 'proc'
rbind_host_dir "${MOUNT_POINT}" "tmp/root" '/'
rbind_host_dir "${MOUNT_POINT}" 'sys'

mount --verbose --types tmpfs --options 'mode=0755' none "$MOUNT_POINT/run"
TRACK_MOUNTS+=("$MOUNT_POINT/run")
mount --verbose --types tmpfs --options 'mode=0755' none \
  "$MOUNT_POINT/var/setuid-wrappers"
TRACK_MOUNTS+=("$MOUNT_POINT/var/setuid-wrappers")
if [ -e "${MOUNT_POINT}/var/run" ]; then
  rm --verbose --recursive --force "$MOUNT_POINT/var/run"
fi
ln --verbose --symbolic '/run' "$MOUNT_POINT/var/run"

if [ -n "$runChroot" ]; then
  if ! [ -L "$MOUNT_POINT/nix/var/nix/profiles/system" ]; then
    echo "$0: installation not finished; cannot chroot into installation directory" >&2
    exit 1
  fi
  ln --verbose --symbolic \
    '/nix/var/nix/profiles/system' "$MOUNT_POINT/run/current-system"
  exec chroot "$MOUNT_POINT" "${chrootCommand[@]}"
fi

chown @root_uid@:@nixbld_gid@ "$MOUNT_POINT/nix/store"

# There is no daemon in the chroot.
unset NIX_REMOTE

# We don't have locale-archive in the chroot, so clear $LANG.
export LANG=
export LC_ALL=
export LC_TIME=

# Builds will use users that are members of this group
extraBuildFlags+=('--option' 'build-users-group' "$buildUsersGroup")

# Inherit binary caches from the host
binary_caches="$(
  @perl@/bin/perl -I @nix@/lib/perl5/site_perl/*/* \
    -e 'use Nix::Config; Nix::Config::readConfig; print $Nix::Config::config{"binary-caches"};'
)"
extraBuildFlags+=('--option' 'binary-caches' "$binary_caches")

# Copy Nix to the Nix store on the target device, unless it's already there.
if ! NIX_DB_DIR="$MOUNT_POINT/nix/var/nix/db" nix-store --check-validity '@nix@' 2> /dev/null; then
  echo "copying Nix to $MOUNT_POINT...." >&2
  for i in $(@perl@/bin/perl @pathsFromGraph@ @nixClosure@); do
    echo "  $i" >&2
    chattr -R -i "$MOUNT_POINT/$i" 2> /dev/null || true  # clear immutable bit
    @rsync@/bin/rsync ${debugFlags:+--verbose} --archive "$i" "$MOUNT_POINT/nix/store/"
  done

  # Register the paths in the Nix closure as valid.  This is necessary
  # to prevent them from being deleted the first time we install
  # something.  (i.e. Nix will see that glibc's path is not valid,
  # delete it to get it out of the way, but as a result nothing will
  # work anymore.)
  chroot "$MOUNT_POINT" \
    '@nix@/bin/nix-store' --register-validity < '@nixClosure@'
fi

# !!! assuming that @shell@ is in the closure
ln --verbose --symbolic --force '@shell@' "$MOUNT_POINT/bin/sh"

# Build hooks likely won't function correctly in the minimal chroot
unset NIX_BUILD_HOOK

# Make the build below copy paths from the host if possible.  Note that
# /tmp/root in the chroot is the root of the host.
export NIX_OTHER_STORES="/tmp/root/nix:$NIX_OTHER_STORES"

nix_substituters_a=(
  '@nix@/libexec/nix/substituters/copy-from-other-stores.pl'
  '@nix@/libexec/nix/substituters/download-from-binary-cache.pl'
)
for nix_substituter in "${nix_substituters_a[@]}"; do
  NIX_SUBSTITUTERS="${NIX_SUBSTITUTERS}${NIX_SUBSTITUTERS:+:}${nix_substituter}"
done
export NIX_SUBSTITUTERS

# Make manifests available in the chroot.
rm --verbose --force "${MOUNT_POINT}/nix/var/nix/manifests"/* || true
for i in /nix/var/nix/manifests/*.nixmanifest; do
  chroot "$MOUNT_POINT" \
    '@nix@/bin/nix-store' -r "$(readlink --canonicalize "$i")" > /dev/null
  cp --verbose --preserve="links,mode,ownership,timestamps" \
    --no-dereference "$i" "$MOUNT_POINT/nix/var/nix/manifests/"
done

if [ -z "$closure" ]; then
  # Get the absolute path to the NixOS/Nixpkgs sources.
  nixpkgs="$(readlink --canonicalize "$(nix-instantiate --find-file nixpkgs)")"

  nixEnvAction="-f <nixpkgs/nixos> --set -A system"
else
  nixpkgs=""
  nixEnvAction="--set $closure"
fi

# Build the specified Nix expression in the target store and install
# it into the system configuration profile.
echo 'building the system configuration...' >&2
NIX_PATH="nixpkgs=/tmp/root/$nixpkgs:nixos-config=$NIXOS_CONFIG" NIXOS_CONFIG= \
  chroot "$MOUNT_POINT" \
    '@nix@/bin/nix-env' "${extraBuildFlags[@]}" \
      -p '/nix/var/nix/profiles/system' $nixEnvAction

# Copy the NixOS/Nixpkgs sources to the target as the initial contents
# of the NixOS channel.
srcs=$(
  nix-env "${extraBuildFlags[@]}" \
    -p '/nix/var/nix/profiles/per-user/root/channels' \
    -q 'nixos' \
    --no-name \
    --out-path 2>/dev/null || echo -n ""
)
if [ -z "$noChannelCopy" ] && [ -n "$srcs" ]; then
  echo 'copying NixOS/Nixpkgs sources...' >&2
  chroot "$MOUNT_POINT" '@nix@/bin/nix-env' \
      "${extraBuildFlags[@]}" \
      -p '/nix/var/nix/profiles/per-user/root/channels' \
      -i "$srcs" \
      --quiet
fi
ln --verbose --symbolic --force --no-dereference \
  '/nix/var/nix/profiles/per-user/root/channels' \
  "$MOUNT_POINT/root/.nix-defexpr/channels"

# Get rid of the /etc bind mounts.
for f in '/etc/passwd' '/etc/group'; do
  if [ -f "$f" ]; then
    umount ${debugFlags:+--verbose} "$MOUNT_POINT/$f"
  fi
done

# Grub needs an mtab.
ln --symbolic --force --no-dereference '/proc/mounts' "$MOUNT_POINT/etc/mtab"

# Mark the target as a NixOS installation, otherwise
# switch-to-configuration will chicken out.
touch "$MOUNT_POINT/etc/NIXOS"

# Switch to the new system configuration.  This will install Grub with
# a menu default pointing at the kernel/initrd/etc of the new
# configuration.
echo 'finalising the installation...' >&2
if [ -z "$noBootLoader" ]; then
  NIXOS_INSTALL_BOOTLOADER=1 chroot "$MOUNT_POINT" \
    '/nix/var/nix/profiles/system/bin/switch-to-configuration' boot
fi

# Run the activation script.
chroot "$MOUNT_POINT" '/nix/var/nix/profiles/system/activate'

# Ask the user to set a root password.
if [ -z "$noRootPasswd" ] && [ -x "$MOUNT_POINT/var/setuid-wrappers/passwd" ] && [ -t 0 ]; then
  echo "setting root password..." >&2
  chroot "$MOUNT_POINT" '/var/setuid-wrappers/passwd'
fi

echo 'installation finished!' >&2
