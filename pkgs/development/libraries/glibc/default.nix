{ stdenv
, fetchurl
, fetchTritonPatch
, linux-headers
, patchelf
, installLocales ? false
}:

import ./common.nix {
  name = "glibc";

  inherit fetchurl fetchTritonPatch stdenv linux-headers installLocales;

  # This is a hack to bring in the setup hook
  nativeBuildInputs = [
    patchelf
  ];

  installTargets = [
    "install"
  ] ++ stdenv.lib.optionals installLocales [
    "localedata/install-locales"
  ];

  preBuild = ''
    export stackProtector=0
    echo "build-programs=no" >> configparams
  '';

  postBuild = ''
    export stackProtector=1
    sed -i 's,build-programs=no,build-programs=yes,g' configparams
    make -j $NIX_BUILD_CORES $makeFlags "''${makeFlagsArray[@]}" $buildFlags "''${buildFlagsArray[@]}"
  '';

  postInstall = ''
    rm $out/etc/ld.so.cache

    # Include the Linux kernel headers in Glibc, except the `scsi'
    # subdirectory, which Glibc provides itself.
    (cd $out/include && \
     ln -sv $(ls -d ${linux-headers}/include/* | grep -v 'scsi''$') .)

    # ldd has a preconfigured bad list of ld.so loaders
    # Rewrite that variable in the ldd script so it finds the
    # loaders correctly.
    # We can find the loaders by simply looking for ld*.so*
    # in the ouput folder
    RTLDLIST="$(find $out -name ld\*.so\* | tr '\n' ' ')"
    sed -i "s,^RTLDLIST=.*,RTLDLIST=\"$RTLDLIST\",g" $out/bin/ldd

    # Test that ldd works
    $out/bin/ldd $out/lib/libcrypt.so

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
      chmod u+w $out/lib/libgcc_s.so.1
      patchelf --set-rpath $out/lib --force-rpath $out/lib/libgcc_s.so.1
      # the .so It used to be a symlink, but now it is a script
      cp -a ${stdenv.cc.cc}/lib/libgcc_s.so $out/lib/libgcc_s.so
    fi
  '';

  meta.description = "The GNU C Library";
}
