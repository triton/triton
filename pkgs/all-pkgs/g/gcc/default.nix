{ stdenv
, binutils
, fetchTritonPatch
, fetchurl

, gmp
, isl
, libmpc
, linux-headers
, mpfr
, zlib

, target ? null
, type ? "full"
, fakeCanadian ? false
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optional
    optionals
    optionalAttrs
    optionalString
    stringLength;

  checking =
    if type == "bootstrap" then
      "yes"
    else
      "release";

  commonConfigureFlags = [
    (optionalString (target != null) "--target=${target}")
    "--${boolEn (type != "bootstrap")}-gcov"
    "--disable-multilib"
    "--disable-bootstrap"
    "--enable-languages=c,c++"
    "--disable-werror"
    "--enable-checking=${checking}"
    "--${boolEn (type != "bootstrap")}-nls"
    "--enable-cet=auto"
    "--with-glibc-version=2.28"
  ];

  types = {
    "all" = rec {
      version = "10-20200216";
      name = "gcc-${version}";
      src = fetchurl {
        url = "https://bigsearcher.com/mirrors/gcc/snapshots/${version}/${name}.tar.xz";
        hashOutput = false;
        sha256 = "f7f129d4884eb9f7173018be2188c76e1f4bf0795a79c244cf6b6964e153961d";
      };
    };
    "bootstrap" = rec {
      version = "9.3.0";
      name = "gcc-${version}";
      src = fetchurl {
        url = "mirror://gnu/gcc/${name}/${name}.tar.xz";
        hashOutput = false;
        sha256 = "eaaef08f121239da5695f76c9b33637a118dcf63e24164422231917fa61fb206";
      };
    };
  };

  inherit (types."${type}" or types.all)
    version
    name
    src;
in
stdenv.mkDerivation rec {
  inherit name src;

  nativeBuildInputs = [
    binutils.bin
  ];

  buildInputs = optionals (type != "bootstrap") [
    gmp
    isl
    libmpc
    mpfr
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "07997b8b1232810806ea323cc44d460ee78c1174";
      file = "g/gcc/9.1.0/0001-libcpp-Enforce-purity-BT_TIMESTAMP.patch";
      sha256 = "0d5754d2262fcc349edd8eabe20ddd04494593965859b9e37ee983a6bdc4c47f";
    })
    (fetchTritonPatch {
      rev = "07997b8b1232810806ea323cc44d460ee78c1174";
      file = "g/gcc/9.1.0/0002-c-ada-spec-Workaround-for-impurity-detection.patch";
      sha256 = "156d4a1c885c28b4b4196ceed3ba7b2da0c1fdcc0261e4222c2cfc06296c53ec";
    })
    (fetchTritonPatch {
      rev = "07997b8b1232810806ea323cc44d460ee78c1174";
      file = "g/gcc/9.1.0/0003-gcc-Don-t-hardcode-startfile-locations.patch";
      sha256 = "b5e0f27cf755b066df82d668a3728b28a1a13359272ffe37e106e1164eb3a81f";
    })
    (fetchTritonPatch {
      rev = "07997b8b1232810806ea323cc44d460ee78c1174";
      file = "g/gcc/9.1.0/0004-cppdefault-Don-t-add-a-default-local_prefix-include.patch";
      sha256 = "410f5251b08493d0917018a28fcabe468762e1edc5050fa23fdcc02c30a9c79f";
    })
  ];

  prePatch = optionalString (type == "bootstrap") ''
    ! test -e gmp
    unpackFile '${gmp.src}'
    mv gmp-* gmp
    ! test -e mpc
    unpackFile '${libmpc.src}'
    mv mpc-* mpc
    ! test -e mpfr
    unpackFile '${mpfr.src}'
    mv mpfr-* mpfr
  '';

  # We need to use the proper objdump tool for our build
  postPatch = ''
    grep -q 'export_sym_check.*"objdump' libcc1/configure
    sed -i '/export_sym_check/s,"objdump,"$OBJDUMP,' {gcc,libcc1}/configure
  '' + optionalString fakeCanadian ''
    sed -i 's,@GCC_FOR_TARGET@,$$r/$(HOST_SUBDIR)/gcc/xgcc -B$$r/$(HOST_SUBDIR)/gcc/,' Makefile.in
  '';

  prefix = placeholder "bin";

  configureFlags = commonConfigureFlags ++ [
    "--enable-host-shared"
    "--${boolEn (type != "bootstrap")}-lto"
    "--enable-linker-build-id"
    "--${boolWt (type != "bootstrap")}-system-zlib"
    "--without-headers"
    "--with-newlib"
    "--with-local-prefix=/no-such-path/local-prefix"
    "--with-native-system-header-dir=/no-such-path/native-headers"
  ];

  preConfigure = ''
    mkdir -v build
    cd build
    configureScript='../configure'
    configureFlags+=("--with-debug-prefix-map=$NIX_BUILD_TOP=/no-such-path")
  '' + optionalString (type != "bootstrap") ''
    # Not autodetected during cross compiles
    export gcc_cv_initfini_array='yes'
  '';

  preBuild = ''
    sed -i '/^TOPLEVEL_CONFIGURE_ARGUMENTS=/d' Makefile
  '';

  buildFlags = [
    "all-host"
  ];

  installTargets = [
    "install-host"
  ];

  postInstall = ''
    rm -v "$bin"/bin/*-${version}

    # GCC won't include our libc limits.h if we don't fix it
    ! test -e "$bin"/lib/gcc/*/*/include-fixed/limits.h
    cat ../gcc/{limitx.h,glimits.h,limity.h} >"$bin"/lib/gcc/*/*/include-fixed/limits.h

    find "$bin" -name '*'.la -delete

    rm -rv "$bin"/lib/gcc/*/*/install-tools
    mkdir -p "$plugin_dev" "$plugin_lib/lib"
    mv -v "$bin"/lib/gcc/*/*/plugin "$plugin_dev"
    mv -v "$plugin_dev"/plugin/*.so* "$plugin_lib"/lib
    ln -sv "$plugin_lib"/lib/* "$plugin_dev"/plugin

    mkdir -p "$cc_headers"
    mv -v "$bin"/lib/gcc/*/*/include "$cc_headers"
    mv -v "$bin"/lib/gcc/*/*/include-fixed "$cc_headers"
    mkdir -p "$cc_headers"/nix-support
    echo "-idirafter $cc_headers/include" >>"$cc_headers"/nix-support/stdinc
    echo "-idirafter $cc_headers/include-fixed" >>"$cc_headers"/nix-support/stdinc

    mkdir -p "$lib"/lib "$dev"/lib
    mv -v "$bin"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib

    mv -v "$bin"/include "$dev"
    rmdir "$bin"/lib/gcc/*/* "$bin"/lib/gcc/* "$bin"/lib/gcc "$bin"/lib

    pfx=
  '' + optionalString (target != null) ''
    if [ -e "$bin"/bin/${target}-gcc ]; then
      pfx=${target}-
    fi
  '' + optionalString (target == null) ''
    rm -rv "$bin"/bin/"$NIX_SYSTEM_HOST"-*
  '' + ''
    # CC does not get installed for some reason
    ln -srv "$bin"/bin/''${pfx}gcc "$bin"/bin/''${pfx}cc

    find . -not -type d -and -not -name '*'.mvars -and -not -name Makefile -and -not -name '*'.h -delete
    find . -type f -exec sed -i "s,$NIX_BUILD_TOP,/build-dir,g" {} \;
    mkdir -p "$internal"
    tar Jcf "$internal"/build.tar.xz .

    # Hash the tools and deduplicate
    declare -A progMap
    for prog in "$bin"/bin/*; do
      if [ -L "$prog" ]; then
        continue
      fi
      checksum="$(cksum "$prog" | cut -d ' ' -f1)"
      oProg="''${progMap["$checksum"]-}"
      if [ -z "$oProg" ]; then
        progMap["$checksum"]="$prog"
      elif cmp "$prog" "$oProg"; then
        rm "$prog"
        ln -srv "$oProg" "$prog"
      fi
    done

    # We don't need the install-tools for anything
    # They sometimes hold references to interpreters
    rm -rv "$bin"/libexec/gcc/*/*/install-tools
  '';

  postFixup = ''
    mkdir -p "$bin"/share2
  '' + optionalString (type == "full") ''
    mv "$bin"/share/locale "$bin"/share2
  '' + ''
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "cc_headers"
    "plugin_dev"
    "plugin_lib"
    "internal"
  ] ++ optionals (type == "full") [
    "man"
  ];

  passthru = {
    inherit target version commonConfigureFlags;
    impl = "gcc";
    external = false;

    cc = "gcc";
    cxx = "g++";
    optFlags = [ ];
    prefixMapFlag = "file-prefix-map";
    canStackClashProtect = true;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
