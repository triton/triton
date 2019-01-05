{ stdenv
, binutils
, bison
, fetchurl
, fetchTritonPatch
, gcc
, linux-headers

, type ? "full"
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optional
    optionals
    optionalString;

  host =
    if type == "bootstrap" then
      "x86_64-tritonboot-linux-gnu"
    else
      "x86_64-pc-linux-gnu";
in
stdenv.mkDerivation rec {
  name = "glibc-2.28";

  src = fetchurl {
    url = "mirror://gnu/glibc/${name}.tar.xz";
    hashOutput = false;
    sha256 = "b1900051afad76f7a4f73e71413df4826dce085ef8ddb785a945b66d7d513082";
  };

  nativeBuildInputs = [
    bison
    binutils
    gcc
  ];

  # Some of the tools depend on a shell. Set to impure /bin/sh to
  # prevent a retained dependency on the bootstrap tools in the stdenv-linux
  # bootstrap.
  BASH_SHELL = "/bin/sh";

  patches = [
    (fetchTritonPatch {
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "g/glibc/0001-Fix-common-header-paths.patch";
      sha256 = "e783d2ee9c097779c83217f68c13eff2e08fa23597a860b759178918f78e3928";
    })
    (fetchTritonPatch {
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "g/glibc/0002-sunrpc-Don-t-hardcode-cpp-path.patch";
      sha256 = "889b177579a48e541be06667201202264bbb91c923c5513c054f3183132d35e7";
    })
    (fetchTritonPatch {
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "g/glibc/0003-timezone-Fix-zoneinfo-path-for-triton.patch";
      sha256 = "b8393292005f1df26eddeb64fd3ff18df62d861f91e926a75323214d0b4a7f32";
    })
    (fetchTritonPatch {
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "g/glibc/0004-nsswitch-Try-system-paths-for-modules.patch";
      sha256 = "3fd11d14cdf54704c5c7bf20ba3548bec5803d8cffc01c21e7410ed85b91cb8d";
    })
  ];

  # We don't want to rewrite the paths to our dynamic linkers for ldd
  # Just use the paths as-is.
  postPatch = ''
    grep -q '^ldd_rewrite_script=' sysdeps/unix/sysv/linux/x86_64/configure
    find sysdeps -name configure -exec sed -i '/^ldd_rewrite_script=/d' {} \;
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--host=${host}"
    "--disable-maintainer-mode"
    "--enable-stackguard-randomization"
    "--enable-bind-now"
    "--enable-stack-protector=strong"
    "--enable-kernel=${linux-headers.channel}"
    "--disable-werror"
    "--${boolEn (type == "full")}-build-nscd"
    "--with-binutils=${binutils}"
    "--with-headers=${linux-headers}/include"
  ];

  preConfigure = ''
    mkdir -v build
    cd build
    configureScript='../configure'
  '';

  preBuild = ''
    # We don't want to use the ld.so.cache from the system
    grep -q '#define USE_LDCONFIG' config.h
    echo '#undef USE_LDCONFIG' >>config.h
  '';

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  # Don't retain shell referencs
  dontPatchShebangs = true;

  # We can't have references to any of our bootstrapping derivations
  allowedReferences = [ "out" ];

  passthru = {
    impl = "glibc";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
