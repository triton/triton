BINS="awk basename bash bzip2 cat chmod cksum cmp cp cut date diff dirname \
     egrep env expr false fgrep find gawk grep gzip head id install join ld \
     ln ls make mkdir mktemp mv nl nproc od patch readlink rm rmdir sed sh \
     sleep sort stat tar tail tee test touch tsort tr true xz xargs uname uniq wc"
COMPILERS="as ar gcc g++ ld objdump ranlib readelf strip"

echo Unpacking the bootstrap tools...
export PATH=/bin:/usr/bin:/run/current-system/sw/bin
if gcc --help >/dev/null 2>&1; then
  echo Using native tooling
  findbin() {
    local oldifs="$IFS"
    IFS=:
    local found=
    for p in $PATH; do
      if [ -e "$p"/$1 ]; then
        found="$p"/$1
        break
      fi
    done
    if [ -z "$found" ]; then
      echo "Failed to find: $1" >&2
      exit 1
    fi
    echo "$found"
    IFS="$oldifs"
  }
  mkdir -p "$out"/bin "$compiler"/bin
  for util in $BINS; do
    ln -sv "$(findbin "$util")" "$out"/bin/$util
  done
  for util in $COMPILERS; do
    ln -sv "$(findbin "$util")" "$compiler"/bin/$util
  done
  exit 0
fi

set -x
# Unpack the bootstrap tools tarball.
$busybox mkdir $out
< $tarball $busybox unxz | $busybox tar x -C $out

# Set the ELF interpreter / RPATH in the bootstrap binaries.
echo Patching the bootstrap tools...

# On x86_64, ld-linux-x86-64.so.2 barfs on patchelf'ed programs.  So
# use a copy of patchelf.
LD_LIBRARY_PATH=$out/lib $out/lib/ld-*.so $out/bin/cp $out/bin/patchelf $out/lib/*.so* .
patchelf() {
  LD_LIBRARY_PATH=. ./ld-*so ./patchelf "$@"
}
case "$(LD_LIBRARY_PATH=$out/lib $out/lib/ld-*.so $out/bin/gcc -dumpmachine)" in
  powerpc*)
    PATCHELF_PAGE_SIZE=65536
    ;;
  i[0-9]86*|x86_64*)
    PATCHELF_PAGE_SIZE=4096
    ;;
  *)
    exit 1
    ;;
esac

for i in $(LD_LIBRARY_PATH=. ./ld-*.so "$out"/bin/find "$out" -type f); do
  if ! patchelf "$i" 2>/dev/null; then continue; fi
  echo Patching "$i"
  args=""
  if [ -n "$(patchelf --print-interpreter "$i" 2>/dev/null)" ]; then
    args="$args --set-interpreter $(echo $out/lib/ld-*.so)"
  fi
  if [ -n "$(patchelf --print-rpath "$i" 2>/dev/null)" ]; then
    args="$args --set-rpath $out/lib"
  fi
  if [ -n "$args" ]; then
    patchelf --page-size $PATCHELF_PAGE_SIZE $args "$i"
  fi
done

$out/bin/mv $out/bin $out/sbin
export PATH="$out"/sbin
mkdir -p "$out"/bin "$compiler"/bin

# Link all of the needed tools
for util in $BINS; do
  [ -e "$out"/bin/$util ] && continue
  if [ ! -e "$out"/sbin/$util ]; then
    echo "Failed to find: $util" >&2
    exit 1
  fi
  ln -sv ../sbin/$util "$out"/bin/$util
done
for util in $COMPILERS; do
  [ -e "$compiler"/bin/$util ] && continue
  if [ ! -e "$out"/sbin/$util ]; then
    echo "Failed to find: $util" >&2
    exit 1
  fi
  ln -sv "$out"/sbin/$util "$compiler"/bin/$util
done

# Make sure the cc-wrapper picks up the right thing
mkdir -p "$compiler"/nix-support
cxxinc="$(dirname "$(dirname "$out"/include-c++/*/bits/c++config.h)")"
echo "-idirafter $cxxinc" >>"$compiler"/nix-support/stdincxx
echo "-idirafter $(dirname "$cxxinc")" >>"$compiler"/nix-support/stdincxx
echo "-idirafter $out/include-gcc" >>"$compiler"/nix-support/stdinc
echo "-idirafter $out/include-fixed-gcc" >>"$compiler"/nix-support/stdinc
echo "-idirafter $out/include" >>"$compiler"/nix-support/stdinc
echo "-B$out/lib" >>"$compiler"/nix-support/cflags
dyld="$(echo "$out"/lib/ld-*.so)"
echo -n "$dyld" >>"$compiler"/nix-support/dynamic-linker
echo "-L$out/lib" >>"$compiler"/nix-support/ldflags
