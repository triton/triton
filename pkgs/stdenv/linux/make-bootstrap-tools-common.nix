{ stdenv
, nukeReferences
, cpio
, readelf

, bash
, binutils
, bison
, coreutils
, diffutils
, findutils
, flex
, gawk
, glibc
, gnused
, gnugrep
, gnum4
, gnutar
, brotli
, gzip
, bzip2
, xz
, gnumake
, gnupatch
, patchelf
, curl
, openssl
, gcc
, pkgconfig
, busybox
}:

rec {
  build = stdenv.mkDerivation {
    name = "stdenv-bootstrap-tools";

    nativeBuildInputs = [
      nukeReferences
      cpio
    ];

    buildCommand = ''
      set -x
      mkdir -p $out/bin $out/lib $out/libexec
    '' +
    /* Copy what we need of Glibc. */ ''
      cp -d ${glibc}/lib/{*.so*,*.a,*crt*.o} $out/lib
      chmod -R u+w $out/lib
      cp -rL ${glibc}/include $out
      chmod -R u+w $out/include
    '' +
    /* Hopefully we won't need these. */ ''
      rm -rf $out/include/mtd $out/include/rdma $out/include/sound $out/include/video
      find $out/include -name \*.install\* -exec rm {} \;
      mv $out/include $out/include-glibc
    '' +
    /* Copy coreutils, bash, etc. */ ''
      cp -v "${coreutils}"/bin/* "$out"/bin
      cp -v "${bash}"/bin/bash "$out"/bin
      ln -sv bash "$out"/bin/sh
      cp -v "${findutils}"/bin/{find,xargs} "$out"/bin
      cp -v "${diffutils}"/bin/{cmp,diff} "$out"/bin
      cp -v "${gnused}"/bin/sed "$out"/bin
      cp -v "${gnugrep}"/bin/grep "$out"/bin
      cp -v "${gawk}"/bin/gawk "$out"/bin
      ln -sv gawk "$out"/bin/awk
      cp -v "${gnutar}"/bin/tar "$out"/bin
      cp -v "${gzip}"/bin/gzip "$out"/bin
      cp -v "${bzip2}"/bin/bzip2 "$out"/bin
      cp -v "${xz}"/bin/xz "$out"/bin
      cp -v "${gnumake}"/bin/make "$out"/bin
      cp -v "${gnupatch}"/bin/patch "$out"/bin
      cp -v "${gnum4}"/bin/m4 "$out"/bin
      cp -v "${bison}"/bin/bison "$out"/bin
      echo "#!/bin/sh" > "$out"/bin/yacc
      echo 'exec "$(dirname "$0")"/bison -y "$@"' >> "$out"/bin/yacc
      chmod +x "$out"/bin/yacc
      mkdir -p "$out"/share
      cp -rv "${bison}"/share/bison "$out"/share
      cp -v "${flex}"/bin/flex "$out"/bin
    '' +
    /* Copy what we need of GCC. */ ''
      cp -d "${gcc}"/bin/{cpp,g++,gcc} "$out"/bin
      cp -d ${gcc}/lib/{*.a,*.so*} $out/lib
      chmod -R u+w $out/lib
      cp -rd ${gcc}/lib/gcc $out/lib
      chmod -R u+w $out/lib
      rm -f $out/lib/gcc/*/*/include*/linux
      rm -f $out/lib/gcc/*/*/include*/sound
      rm -rf $out/lib/gcc/*/*/include*/root
      rm -f $out/lib/gcc/*/*/include-fixed/asm
      rm -rf $out/lib/gcc/*/*/plugin
      cp -rd ${gcc}/libexec/* $out/libexec
      chmod -R u+w $out/libexec
      rm -rf $out/libexec/gcc/*/*/plugin
      mkdir $out/include
      cp -rd ${gcc}/include/c++ $out/include
      chmod -R u+w $out/include
      rm -rf $out/include/c++/*/ext/pb_ds
      rm -rf $out/include/c++/*/ext/parallel
    '' +
    /* Copy binutils. */ ''
      cp -v "${binutils}"/bin/{ar,as,ld,ranlib,strip} "$out"/bin
    '' +
    /* We need patchelf to deal with fixing binaries after unpack */ ''
      cp -v "${patchelf}/bin/patchelf" "$out"/libexec
    '' +
    /* Copy all of the needed libraries for the binaries */ ''
      copy_libs_in_elf() {
        local BIN; local RELF; local RPATH; local LIBS; local LIB; local LINK;
        BIN=$1
        # Determine what libraries are needed by the elf
        set +x
        RELF="$(${readelf} -a $BIN 2>&1)" || continue
        if RPATH="$(echo "$RELF" | grep rpath | sed 's,.*\[\([^]]*\)\].*,\1,')" &&
          LIBS="$(echo "$RELF" | grep 'Shared library' | sed 's,.*\[\([^]]*\)\].*,\1,')"; then
          set -x
          for LIB in $LIBS; do
            # Find the libraries on the system
            for LIBPATH in $(echo "$RPATH" | tr ':' ' '); do
              if [ -f "$LIBPATH/$LIB" ]; then
                LIB="$LIBPATH/$LIB"
                break
              fi
            done
            # Copy the library and possibly symlinks
            while [ ! -f "$out/lib/$(basename $LIB)" ]; do
              LINK="$(readlink $LIB)" || true
              if [ -z "$LINK" ]; then
                cp -pdv $LIB $out/lib
                copy_libs_in_elf $LIB
                break
              else
                ln -sv "$(basename $LINK)" "$out/lib/$(basename $LIB)"
                if [ "${LINK:0:1}" != "/" ]; then
                  LINK="$(dirname $LIB)/$LINK"
                fi
                LIB="$LINK"
              fi
            done
          done
        else
          set -x
          echo "ELF is not dynamic: $BIN" >&2
        fi
      }
      for BIN in $out/bin/* $out/libexec/gcc/*/*/*; do
        echo "Copying libs for bin $BIN"
        copy_libs_in_elf $BIN
      done

      chmod -R u+w $out
    '' +
    /* Strip executables even further. */ ''
      for i in $out/bin/* $out/libexec/gcc/*/*/*; do
          if test -x $i -a ! -L $i; then
              chmod +w $i
              strip -s $i || true
          fi
      done

      nuke-refs $out/bin/*
      nuke-refs $out/lib/*
      nuke-refs $out/libexec/*
      nuke-refs $out/libexec/gcc/*/*/*

      mkdir $out/.pack
      mv $out/* $out/.pack
      mv $out/.pack $out/pack
      #
      mkdir $out/on-server
      tar --sort=name --owner=0 --group=0 --numeric-owner \
        --no-acls --no-selinux --no-xattrs \
        --mode=go=rX,u+rw,a-s \
        --clamp-mtime --mtime=@946713600 \
        -c -C "$out/pack" . | xz -9 -e > "$out"/on-server/bootstrap-tools.tar.xz
      cp ${busybox}/bin/busybox $out/on-server/bootstrap-busybox
      chmod u+w $out/on-server/bootstrap-busybox
      nuke-refs $out/on-server/bootstrap-busybox
      set +x
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
      echo "file tarball ${build}/on-server/bootstrap-tools.tar.xz" >> $out/nix-support/hydra-build-products
      echo "file busybox ${build}/on-server/busybox" >> $out/nix-support/hydra-build-products
    '';
  };

}
