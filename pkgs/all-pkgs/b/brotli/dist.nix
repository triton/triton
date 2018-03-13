{ stdenv
, autoconf
, automake
, bc
, fetchFromGitHub
, libtool
}:

let
  version = "1.0.3";

  tarFlags = [
    "--sort=name"
    "--owner=0"
    "--group=0"
    "--numeric-owner"
    "--no-acls"
    "--no-selinux"
    "--no-xattrs"
    "--mode=go=rX,u+rw,a-s"
    "--clamp-mtime"
  ];

  xzFlags = [
    "-v"
    "-9"
    "-e"
  ];

  inherit (stdenv.lib)
    concatStringsSep;
in
stdenv.mkDerivation {
  name = "brotli-dist-${version}";

  src = fetchFromGitHub {
    version = "5";
    owner = "google";
    repo = "brotli";
    rev = "v${version}";
    sha256 = "ca0c6e72a9f0905f1b85cb1f79db498a0c8608a1554791bdd197ed1507449e08";
  };
  
  nativeBuildInputs = [
    autoconf
    automake
    bc
    libtool
  ];

  postPatch = ''
    ! grep -q 'c/enc/params.h' scripts/sources.lst
    sed -i '/BROTLI_ENC_H/ac/enc/params.h \\' scripts/sources.lst
  '';

  preConfigure = ''
    ./bootstrap
  '';

  preBuild = ''
    # Fix bug in the handling of tar flags so we can prepend our own
    grep -q 'tar} chof' Makefile
    sed -i 's,tar} chof,tar} -chof,' Makefile

    buildFlagsArray+=(
      "XZ_OPT=${concatStringsSep " " xzFlags}"
      "TAR=tar ${concatStringsSep " " tarFlags} --mtime=@$SOURCE_DATE_EPOCH"
    )
  '';

  buildFlags = [
    "dist-xz"
  ];

  installPhase = ''
    mkdir -p "$out"
    mv brotli-*.tar* "$out"

    # Make sure the dist builds a valid tarball
    tar tf "$out"/* | grep '^brotli.*/configure$'
  '';
}
