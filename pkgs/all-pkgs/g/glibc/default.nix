{ stdenv
, binutils
, bison
, fetchurl
, fetchTritonPatch
, gcc
, linux-headers
, python_tiny

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

  host =
    if type == "bootstrap" then
      "x86_64-tritonboot-linux-gnu"
    else
      "x86_64-pc-linux-gnu";

  version = "2.29";
in
stdenv.mkDerivation (rec {
  name = "glibc-${version}";

  src = fetchurl {
    url = "mirror://gnu/glibc/${name}.tar.xz";
    hashOutput = false;
    sha256 = "f3eeb8d57e25ca9fc13c2af3dae97754f9f643bc69229546828e3a240e2af04b";
  };

  nativeBuildInputs = [
    bison
    binutils
    gcc
    python_tiny
  ];

  # Some of the tools depend on a shell. Set to impure /bin/sh to
  # prevent a retained dependency on the bootstrap tools in the stdenv-linux
  # bootstrap.
  BASH_SHELL = "/bin/sh";

  patches = [
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0001-Fix-common-header-paths.patch";
      sha256 = "df93cbd406a5dd2add2dd0d601ff9fc97fc42a1402010268ee1ee8331ec6ec72";
    })
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0002-sunrpc-Don-t-hardcode-cpp-path.patch";
      sha256 = "7a9ce7f69cd6d3426d19a8343611dc3e9c48e3374fa1cb8b93c5c98d7e79d69b";
    })
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0003-timezone-Fix-zoneinfo-path-for-triton.patch";
      sha256 = "b4b47be63c3437882a160fc8d9b8ed7119ab383b1559599e2706ce8f211a0acd";
    })
    (fetchTritonPatch {
      rev = "081b7a40d174baf95f1979ff15c60b49c8fdc30d";
      file = "g/glibc/0004-nsswitch-Try-system-paths-for-modules.patch";
      sha256 = "9cd235f0699661cbfd0b77f74c538d97514ba450dfba9a3f436adc2915ae0acf";
    })
    (fetchTritonPatch {
      rev = "b772989f030aef70b8b5fd39a3bb04738d50b383";
      file = "g/glibc/0005-locale-archive-Support-multiple-locale-archive-locat.patch";
      sha256 = "3ab23b441e573e51ee67a8e65a3c0c5a40d8d80805838a389b9abca08c45156c";
    })
    (fetchTritonPatch {
      rev = "cf6beafafc0d218cf156e3713fe62c0e53629419";
      file = "g/glibc/0006-Add-C.UTF-8-Support.patch";
      sha256 = "07f61db686dc36bc009999cb8d686581a29b13a0d2dd3f7f0b74cdfe964a0540";
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

  postInstall = ''
    # Ensure we always have a fallback C.UTF-8 locale-archive
    export LOCALE_ARCHIVE="$out"/lib/locale/locale-archive
    mkdir -p "$(dirname "$LOCALE_ARCHIVE")"
    "$out"/bin/localedef -i C -f UTF-8 C.UTF-8

    # Make sure the cc-wrapper doesn't pick this up automagically
    mkdir -p "$out"/nix-support
    touch "$out"/nix-support/cc-wrapper-ignored
  '';

  # Don't retain shell referencs
  dontPatchShebangs = true;

  # We can't have references to any of our bootstrapping derivations
  allowedReferences = [ "out" ];

  passthru = {
    impl = "glibc";
    inherit version;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
} // optionalAttrs (type == "full") {
  setupHook = ./setup-hook.sh;
})
