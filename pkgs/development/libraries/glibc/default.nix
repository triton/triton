{ stdenv
, fetchurl
, fetchTritonPatch
, linux-headers
, installLocales ? false
, profilingLibraries ? false
, gccCross ? null
}:

import ./common.nix {
  name = "glibc";

  inherit fetchurl fetchTritonPatch stdenv linux-headers installLocales
    profilingLibraries gccCross;

  preConfigure = stdenv.lib.optionalString (stdenv.targetSystem != stdenv.hostSystem) ''
    sed -i s/-lgcc_eh//g "../$sourceRoot/Makeconfig"

    cat > config.cache << "EOF"
    libc_cv_forced_unwind=yes
    libc_cv_c_cleanup=yes
    libc_cv_gnu89_inline=yes
    EOF
    export BUILD_CC=gcc
    export CC="$targetSystem-gcc"
    export AR="$targetSystem-ar"
    export RANLIB="$targetSystem-ranlib"

    dontStrip=1
  '';

  installTargets = [
    "install"
  ] ++ stdenv.lib.optionals installLocales [
    "localedata/install-locales"
  ];

  postInstall = ''
    rm $out/etc/ld.so.cache

    # Include the Linux kernel headers in Glibc, except the `scsi'
    # subdirectory, which Glibc provides itself.
    (cd $out/include && \
     ln -sv $(ls -d ${linux-headers}/include/* | grep -v 'scsi''$') .)

    # Fix for NIXOS-54 (ldd not working on x86_64).  Make a symlink
    # "lib64" to "lib".
    #if test -n "$is64bit"; then
    #  ln -s lib $out/lib64
    #fi

    # Get rid of more unnecessary stuff.
    rm -rf $out/var $out/sbin/sln
  '';

  # When building glibc from bootstrap-tools, we need libgcc_s at RPATH for
  # any program we run, because the gcc will have been placed at a new
  # store path than that determined when built (as a source for the
  # bootstrap-tools tarball)
  # Building from a proper gcc staying in the path where it was installed,
  # libgcc_s will not be at {gcc}/lib, and gcc's libgcc will be found without
  # any special hack.
  preInstall = stdenv.lib.optionalString (stdenv.targetSystem == stdenv.hostSystem) ''
    if [ -f ${stdenv.cc.cc}/lib/libgcc_s.so.1 ]; then
      mkdir -p $out/lib
      cp ${stdenv.cc.cc}/lib/libgcc_s.so.1 $out/lib/libgcc_s.so.1
      patchelf --set-rpath $out/lib --force-rpath $out/lib/libgcc_s.so.1
      # the .so It used to be a symlink, but now it is a script
      cp -a ${stdenv.cc.cc}/lib/libgcc_s.so $out/lib/libgcc_s.so
    fi
  '';

  meta.description = "The GNU C Library";
}
