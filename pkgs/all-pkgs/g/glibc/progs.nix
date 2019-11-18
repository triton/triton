{ stdenv
, bison
, cc_gcc_glibc_early
, fetchurl
, fetchTritonPatch
, linux-headers
, python3

, glibc_lib
, type ? "full"
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optional
    optionals
    optionalAttrs
    optionalString;

  inherit (import ./common.nix { inherit fetchurl fetchTritonPatch; })
    src
    patches
    version;
in
(stdenv.override { cc = null; }).mkDerivation rec {
  name = "glibc-progs-${version}";

  inherit
    src
    patches;

  nativeBuildInputs = [
    bison
    cc_gcc_glibc_early
    python3
  ];

  # Some of the tools depend on a shell. Set to impure /bin/sh to
  # prevent a retained dependency on the bootstrap tools in the stdenv-linux
  # bootstrap.
  BASH_SHELL = "/bin/sh";

  # We don't want to rewrite the paths to our dynamic linkers for ldd
  # Just use the paths as-is.
  postPatch = ''
    grep -q '^ldd_rewrite_script=' sysdeps/unix/sysv/linux/x86_64/configure
    find sysdeps -name configure -exec sed -i '/^ldd_rewrite_script=/d' {} \;
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-stackguard-randomization"
    "--enable-bind-now"
    "--enable-stack-protector=strong"
    "--enable-kernel=${linux-headers.channel}"
    "--disable-werror"
    "--${boolEn (type == "full")}-build-nscd"
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

  postInstall = ''
    rm -rf "$out"/{include,lib}
    ln -sv '${glibc_lib.lib}'/lib "$out"/lib
  '';

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
