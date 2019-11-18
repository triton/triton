{ stdenv
, nukeReferences

, bash_small
, binutils
, busybox_bootstrap
, bzip2
, coreutils_small
, diffutils
, findutils
, gawk_small
, glibc_lib_gcc
, gcc
, gcc_lib_glibc
, gcc_runtime_glibc
, gnugrep
, gnumake
, gnupatch_small
, gnused_small
, gnutar_small
, gzip
, linux-headers
, patchelf
, xz
}:

rec {
  build = stdenv.mkDerivation {
    name = "stdenv-bootstrap-tools";

    nativeBuildInputs = [
      nukeReferences
    ];

    binInputs = [
      bash_small.bin
      binutils.bin
      bzip2.bin
      coreutils_small.bin
      diffutils.bin
      findutils.bin
      gawk_small.bin
      gcc.bin
      gnugrep.bin
      gnumake.bin
      gnupatch_small.bin
      gnused_small.bin
      gnutar_small.bin
      gzip.bin
      patchelf.bin
      xz.bin
    ];

    buildCommand = ''
      root="$TMPDIR/root"
      mkdir -pv "$root"/{bin,lib,libexec}

      cp -dv '${glibc_lib_gcc.cc_reqs}'/lib/libc.so "$root"/lib
      cp -dv '${glibc_lib_gcc.dev}'/lib/{libc_nonshared.a,*.o} "$root"/lib
      cp -dv '${gcc_lib_glibc.dev}'/lib/{libgcc_s.so,libgcc.a,*.o} "$root"/lib
      sed -i "s,$NIX_STORE[^ ]*/,,g" "$root"/lib/lib{c,gcc_s}.so
      chmod -R u+w "$root"/lib
      cp -rLv '${linux-headers}'/include "$root"
      chmod -R u+w "$root"/include
      rm -rv "$root"/include/{xen,drm,rdma,sound}
      cp -rLv '${glibc_lib_gcc.dev}'/include "$root"
      chmod -R u+w "$root"/include
      cp -rLv '${gcc.cc_headers}'/include "$root"/include-gcc
      cp -rLv '${gcc.cc_headers}'/include-fixed "$root"/include-fixed-gcc
      cp -rLv '${gcc_runtime_glibc.dev}'/include/c++/* "$root"/include-c++

      declare -A sha256s=()
      copy_bin_and_deps() {
        local file="$1"
        local outdir="$2"

        local outfile="$outdir/$(basename "$file")"
        if [ -e "$outfile" ]; then
          echo "Already have: $outfile" >&2
          return 0
        fi
        mkdir -pv "$outdir"
        sha="$(sha256sum "$file" | awk '{print $1}')"
        if [ -n "''${sha256s["$sha"]-}" ]; then
          ln -srv "''${sha256s["$sha"]}" "$outfile"
          return 0
        fi
        sha256s["$sha"]="$outfile"
        cp -v "$file" "$outfile"
        local needed=""
        needed+=" $(patchelf --print-interpreter "$file" 2>/dev/null)" || true
        needed+=" $(patchelf --print-needed "$file" 2>/dev/null)" || true
        local rpaths=""
        rpaths="$(patchelf --print-rpath "$file" 2>/dev/null | tr ':' ' ')" || true
        local lib
        for lib in $needed; do
          if [ "''${lib:0:1}" = "/" ]; then
            copy_bin_and_deps "$lib" "$root"/lib
            continue
          fi
          local rpath
          for rpath in $rpaths; do
            if [ -e "$rpath/$lib" ]; then
              copy_bin_and_deps "$rpath/$lib" "$root"/lib
              break
            fi
          done
        done
      }

      find_bin() {
        local dir
        for dir in $binInputs; do
          if [ -e "$dir"/bin/$1 ]; then
            echo "$dir"/bin/$1
            return 0
          fi
        done
        return 1
      }

      BINS="awk basename bash bzip2 cat chmod cksum cmp cp cut date diff dirname \
            egrep env expr false fgrep find gawk grep gzip head id install join ld \
            ln ls make mkdir mktemp mv nl nproc od patch readlink rm rmdir sed sh \
            sleep sort stat tar tail tee test touch tsort tr true xz xargs uname uniq wc"
      COMPILERS="as ar gcc g++ ld objdump ranlib readelf strip"
      for bin in patchelf $BINS $COMPILERS; do
        if ! file=$(find_bin "$bin"); then
          echo "Failed to find $bin"
          exit 1
        fi
        copy_bin_and_deps "$file" "$root"/bin
      done
      for file in '${gcc.bin}'/libexec/gcc/*/*/*; do
        test -f "$file" && test -x "$file" || continue
        copy_bin_and_deps "$file" "$(dirname "$root"/''${file#${gcc.bin}})"
      done

      for lib in "$root"/lib/lib*.so*; do
        slib="''${lib%.so*}.so"
        test ! -e "$slib" || continue
        ln -srv "$lib" "$slib"
      done

      nuke-refs "$root"/{bin,lib,libexec}/*

      mkdir -pv "$out"/on-server
      tar --sort=name --owner=0 --group=0 --numeric-owner \
        --no-acls --no-selinux --no-xattrs \
        --mode=go=rX,u+rw,a-s \
        --clamp-mtime --mtime=@946713600 \
        -c -C "$root" . | xz -9 -e > "$out"/on-server/bootstrap-tools.tar.xz
      cp ${busybox_bootstrap}/bin/busybox "$out"/on-server/bootstrap-busybox
      chmod u+w $out/on-server/bootstrap-busybox
      nuke-refs $out/on-server/bootstrap-busybox
    '';

    # The result should not contain any references (store paths) so
    # that we can safely copy them out of the store and to other
    # locations in the store.
    allowedReferences = [ ];
  };

  dist = stdenv.mkDerivation {
    name = "stdenv-bootstrap-dist";

    buildCommand = ''
      mkdir -p $out/nix-support
      echo "file tarball '${build}'/on-server/bootstrap-tools.tar.xz" >> $out/nix-support/hydra-build-products
      echo "file busybox '${build}'/on-server/busybox" >> $out/nix-support/hydra-build-products
    '';
  };

}
