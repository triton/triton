{ stdenv
, autoconf
, automake
, bc
, fetchFromGitHub
, libtool
}:

let
  version = "1.0.4";

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
    version = "6";
    owner = "google";
    repo = "brotli";
    rev = "v${version}";
    sha256 = "333397c592c055a6a63db056a0263a72f0e78110c911838ae2f6c2aa54ac77ef";
  };
  
  nativeBuildInputs = [
    autoconf
    automake
    bc
    libtool
  ];

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
