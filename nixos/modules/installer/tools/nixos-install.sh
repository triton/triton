#!@shell@

# - make Nix store etc.
# - copy closure of Nix to target device
# - register validity
# - with a chroot to the target device:
#   * nix-env -p /nix/var/nix/profiles/system -i <nix-expr for the configuration>
#   * install the boot loader

triton_install_create_directories() {
  local -A -r directories=(
    ['bin']='0755'  # /bin/sh
    ['dev']='755'
    ['etc']='755'
    ['home']='755'
    ['nix']=0755
    ['nix/store']='1775'
    ['nix/var']='0755'
    ['nix/var/log/nix/drvs']='0755'
    ['nix/var/db']='0755'
    ['nix/var/gcroots']='0755'
    ['nix/var/manifests']='0755'
    ['nix/var/nix/profiles']='0755'
    ['nix/var/nix/profiles/per-user']='1777'
    ['nix/var/nix/profiles/per-user/root']='0755'
    ['nix/var/profiles']='0755'
    ['nix/var/temproots']='0755'
    ['nix/var/userpool']='0755'
    ['proc']='755'
    ['root']='0700'
    ['root/.nix-defexpr']='0700'
    ['run']='755'
    ['sys']='755'
    ['tmp']='01777'
    ['tmp/root']='755'
    ['usr/bin']='0755'  # /usr/bin/env
    ['var/setuid-wrappers']='755'
  )
  local directory
  local -r mount_point="${1}"

  # Create directory structure relative to $MOUNT_POINT.
  for directory in "${!directories[@]}"; do
    mkdir \
      --parents \
      --verbose \
      --mode="${directories["${directory}"]}" \
      "${mount_point}/${directory}" || {
        echo "ERROR: failed to create directory: ${mount_point}/${directory}" >&2
        return 1
      }
  done
}

triton_install_mount_directories() {
  local -r mount_point="${1}"

  # Mount some stuff in the target root directory.
  mount --verbose --rbind '/dev' "${MOUNT_POINT}/dev"
  mount --verbose --rbind '/proc' "${MOUNT_POINT}/proc"
  mount --verbose --rbind '/sys' "${MOUNT_POINT}/sys"
  mount --verbose --rbind '/' "${MOUNT_POINT}/tmp/root"
  mount --verbose --types tmpfs \
    --options "mode=0755" none "${MOUNT_POINT}/run"
  mount --verbose --types tmpfs \
    --options "mode=0755" none "${MOUNT_POINT}/var/setuid-wrappers"
}

# Ensure a consistent umask.
umask 0022

# Re-exec ourselves in a private mount namespace so that our bind
# mounts get cleaned up automatically.
if [ $(id -u) -eq 0 ]; then
  if [ -z "$NIXOS_INSTALL_REEXEC" ]; then
    export NIXOS_INSTALL_REEXEC='1'
    exec unshare --mount --uts -- "$0" "$@"
  else
    mount --make-rprivate '/'
  fi
fi

declare -a extraBuildFlags=()
declare -a chrootCommand=('/run/current-system/sw/bin/bash')
buildUsersGroup='nixbld'
MOUNT_POINT='/mnt'

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
      buildUsersGroup=''
      ;;
    '--no-channel-copy')
      noChannelCopy='1'
      ;;
    '--no-root-passwd')
      noRootPasswd='1'
      ;;
    '--no-bootloader')
      noBootLoader='1'
      ;;
    '--show-trace')
      extraBuildFlags+=("$i")
      ;;
    '--chroot')
      runChroot='1'
      if [[ "$@" != "" ]]; then
        chrootCommand=("$@")
      fi
      break
      ;;
    '--help')
      exec man nixos-install
      exit 1
      ;;
    *)
      echo "ERROR: $0: unknown option \`$i'"
      exit 1
      ;;
  esac
done

set -o errexit
set -o pipefail
shopt -s nullglob

if [ ! -e "${MOUNT_POINT}" ]; then
  echo "ERROR: mount point doesn't exist: ${MOUNT_POINT}" >&2
  exit 1
fi

triton_install_create_directories "${MOUNT_POINT}"

triton_install_mount_directories "${MOUNT_POINT}"

rm -rfv "${MOUNT_POINT}/var/run" || :
ln --symbolic --verbose \
  '/run' \
  "${MOUNT_POINT}/var/run"

for f in '/etc/resolv.conf' '/etc/hosts'; do
  rm -fv "${MOUNT_POINT}/$f"
  if [ -f "$f" ]; then
    cp -Lfv "$f" "${MOUNT_POINT}/etc/"
  fi
done

for f in '/etc/passwd' '/etc/group'; do
  touch "${MOUNT_POINT}/$f"
  if [ -f "$f" ]; then
    mount --verbose --rbind --options ro "$f" "${MOUNT_POINT}/$f"
  fi
done

mkdir -p /etc/ssl/certs
for f in /etc/ssl/certs/ca-certificates.crt; do
  rm -f $mountPoint/$f; [ -f "$f" ] && cp -Lf $f $mountPoint/$f
done

if [ -n "$runChroot" ]; then
  if [ ! -L "${MOUNT_POINT}/nix/var/nix/profiles/system" ]; then
    echo "$0: installation not finished; cannot chroot into installation directory"
    exit 1
  fi
  ln --symbolic --verbose \
    '/nix/var/nix/profiles/system' \
    "${MOUNT_POINT}/run/current-system"
  exec chroot "${MOUNT_POINT}" "${chrootCommand[@]}"
fi


# Get the path of the NixOS configuration file.
if [ -z "${NIXOS_CONFIG}" ]; then
  NIXOS_CONFIG='/etc/nixos/configuration.nix'
fi

if [ ! -e "${MOUNT_POINT}/${NIXOS_CONFIG}" ] && [ -z "$closure" ]; then
    echo "ERROR: configuration file doesn't exist: ${MOUNT_POINT}/${NIXOS_CONFIG}" >&2
    exit 1
fi

chown --verbose '@root_uid@:@nixbld_gid@' "${MOUNT_POINT}/nix/store"


# There is no daemon in the chroot.
unset NIX_REMOTE


# We don't have locale-archive in the chroot, so clear $LANG.
export LANG=
export LC_ALL=
export LC_TIME=


# Builds will use users that are members of this group
extraBuildFlags+=('--option' 'build-users-group' "$buildUsersGroup")


# Inherit binary caches from the host
binary_caches="$(@perl@/bin/perl -I @nix@/lib/perl5/site_perl/*/* -e 'use Nix::Config; Nix::Config::readConfig; print $Nix::Config::config{"binary-caches"};')"
extraBuildFlags+=('--option' 'binary-caches' "$binary_caches")


# Copy Nix to the Nix store on the target device, unless it's already there.
if ! NIX_DB_DIR="${MOUNT_POINT}/nix/var/nix/db nix-store" --check-validity @nix@ 2> /dev/null; then
  echo "copying Nix to mount point: ${MOUNT_POINT}" >&2
  for i in $(@perl@/bin/perl @pathsFromGraph@ @nixClosure@); do
    echo "  $i" >&2
    # clear immutable bit
    chattr -R -i "${MOUNT_POINT}/$i" 2> /dev/null || true
    @rsync@/bin/rsync --verbose --archive "$i" "${MOUNT_POINT}/nix/store/"
  done

  # Register the paths in the Nix closure as valid.  This is necessary
  # to prevent them from being deleted the first time we install
  # something.  (I.e., Nix will see that, e.g., the glibc path is not
  # valid, delete it to get it out of the way, but as a result nothing
  # will work anymore.)
  chroot "${MOUNT_POINT}" @nix@/bin/nix-store --register-validity < @nixClosure@
fi


# Create the required /bin/sh symlink; otherwise lots of things
# (notably the system() function) won't work.
# XXX: assuming that @shell@ is in the closure
ln -sfv '@shell@' "${MOUNT_POINT}/bin/sh"


# Build hooks likely won't function correctly in the minimal chroot; just disable them.
unset NIX_BUILD_HOOK

# Make the build below copy paths from the CD if possible.  Note that
# /tmp/root in the chroot is the root of the CD.
export NIX_OTHER_STORES="/tmp/root/nix:$NIX_OTHER_STORES"

p=@nix@/libexec/nix/substituters
export NIX_SUBSTITUTERS=$p/copy-from-other-stores.pl:$p/download-from-binary-cache.pl


# Make manifests available in the chroot.
rm -fv $MOUNT_POINT/nix/var/nix/manifests/*
for i in /nix/var/nix/manifests/*.nixmanifest; do
    chroot $MOUNT_POINT @nix@/bin/nix-store -r "$(readlink -f "$i")" > /dev/null
    cp -pdv "$i" $MOUNT_POINT/nix/var/nix/manifests/
done

if [ -z "$closure" ]; then
  # Get the absolute path to the Triton sources.
  nixpkgs="$(readlink -f $(nix-instantiate --find-file nixpkgs))"

  nixEnvAction='-f <nixpkgs/nixos> --set -A system'
else
  nixpkgs=''
  nixEnvAction="--set $closure"
fi

# Build the specified Nix expression in the target store and install
# it into the system configuration profile.
echo 'building the system configuration...' >&2
NIX_PATH="nixpkgs=/tmp/root/$nixpkgs:nixos-config=$NIXOS_CONFIG" NIXOS_CONFIG= \
  chroot "${MOUNT_POINT}" '@nix@/bin/nix-env' \
  "${extraBuildFlags[@]}" -p '/nix/var/nix/profiles/system' "$nixEnvAction"

# Copy the NixOS/Nixpkgs sources to the target as the initial contents
# of the NixOS channel.
srcs=$(nix-env "${extraBuildFlags[@]}" -p '/nix/var/nix/profiles/per-user/root/channels' -q nixos --no-name --out-path 2>/dev/null || echo -n "")
if [ -z "$noChannelCopy" ] && [ -n "$srcs" ]; then
  echo "copying Triton sources..."
  chroot "$MOUNT_POINT" '@nix@/bin/nix-env' \
    "${extraBuildFlags[@]}" \
    -p '/nix/var/nix/profiles/per-user/root/channels' \
    -i "$srcs" \
    --quiet
fi
ln -sfnv \
  '/nix/var/nix/profiles/per-user/root/channels' \
  "${MOUNT_POINT}/root/.nix-defexpr/channels"

# Remove /etc bind mounts.
for f in '/etc/passwd' '/etc/group' ; do
  if [ -f "$f" ] ; then
    umount --verbose "${MOUNT_POINT}/${f}"
  fi
done

# Create mtab for GRUB.
ln -sfn '/proc/mounts' "${MOUNT_POINT}/etc/mtab"

# Mark the target as a Triton installation, otherwise
# switch-to-configuration will back out.
touch "${MOUNT_POINT}/etc/NIXOS"
#touch "${MOUNT_POINT}/etc/TRITON"

# Switch to the new system configuration.  This will install GRUB with
# a menu default pointing at the kernel/initrd/etc of the new
# configuration.
echo 'finalizing the installation...' >&2
if [ -z "$noBootLoader" ]; then
  NIXOS_INSTALL_BOOTLOADER='1' chroot "$MOUNT_POINT" \
    '/nix/var/nix/profiles/system/bin/switch-to-configuration' 'boot'
fi

# Run the activation script.
chroot "${MOUNT_POINT}" '/nix/var/nix/profiles/system/activate'

# Ask the user to set a root password.
if [ -z "$noRootPasswd" ] && [ -x $MOUNT_POINT/var/setuid-wrappers/passwd ] && [ -t 0 ]; then
    echo "setting root password..." >&2
    chroot "${MOUNT_POINT}" '/var/setuid-wrappers/passwd'
fi

echo 'installation finished!' >&2
