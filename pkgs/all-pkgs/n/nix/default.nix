{ stdenv
, config
, fetchurl
, perl

, boehm-gc
, bzip2
, curl
, libsodium
, openssl
, perlPackages
, sqlite
, xz

, channel ? "stable"

, storeDir ? config.nix.storeDir or "/nix/store"
, stateDir ? config.nix.stateDir or "/nix/var"
}:

let
  inherit ((import ./sources.nix)."${channel}")
    version
    multihash
    sha256;
in
stdenv.mkDerivation rec {
  name = "nix-${version}";

  src = fetchurl {
    url = "https://nixos.org/releases/nix/nix-${version}/nix-${version}.tar.xz";
    inherit multihash sha256;
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    curl
    openssl
    sqlite
    xz
    libsodium
  ];

  propagatedBuildInputs = [
    boehm-gc
  ];

  patches = [
    # Backport commit from triton/nyx
    ./ca-certs.patch
  ];

  # Note: bzip2 is not passed as a build input, because the unpack phase
  # would end up using the wrong bzip2 when cross-compiling.
  # XXX: The right thing would be to reinstate `--with-bzip2' in Nix.
  postUnpack = ''
    export CPATH="${bzip2}/include"
    export LIBRARY_PATH="${bzip2}/lib"
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=${stateDir}"
    "--with-store-dir=${storeDir}"
    "--with-dbi=${perlPackages.DBI}/${perl.libPrefix}"
    "--with-dbd-sqlite=${perlPackages.DBDSQLite}/${perl.libPrefix}"
    "--with-www-curl=${perlPackages.WWWCurl}/${perl.libPrefix}"
    "--disable-init-state"
    "--enable-gc"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "profiledir=$out/etc/profile.d"
    )
  '';

  outputs = [
    "out"
    "doc"
  ];

  meta = with stdenv.lib; {
    description = "Package manager that makes packages reproducible";
    homepage = https://nixos.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
