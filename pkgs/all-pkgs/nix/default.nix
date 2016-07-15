{ stdenv
, fetchurl
, perlPackages

, bzip2
, boehm-gc
, curl
, libsodium
, openssl
, sqlite
, xz

, channel ? "stable"
, storeDir ? "/nix/store"
, stateDir ? "/nix/var"
}:

let
  sources = {
    "stable" = {
      version = "1.11.2";
      url = "http://nixos.org/releases/nix/nix-${version}/nix-${version}.tar.xz";
      sha256 = "fc1233814ebb385a2a991c1fb88c97b344267281e173fea7d9acd3f9caf969d6";
    };
    "unstable" = {
      version = "1.11.2";
      url = "http://nixos.org/releases/nix/nix-${version}/nix-${version}.tar.xz";
      sha256 = "fc1233814ebb385a2a991c1fb88c97b344267281e173fea7d9acd3f9caf969d6";
    };
  };

  inherit (sources."${channel}")
    version
    sha256
    url;
in
stdenv.mkDerivation rec {
  name = "nix-${version}";

  src = fetchurl {
    inherit url sha256;
  };

  nativeBuildInputs = [
    perlPackages.perl
  ];

  buildInputs = [
    boehm-gc
    bzip2
    curl
    libsodium
    openssl
    sqlite
    xz
  ];

  patches = [
    ./ca-certs.patch
  ];

  configureFlags = [
    "--with-store-dir=${storeDir}"
    "--localstatedir=${stateDir}"
    "--sysconfdir=/etc"
    "--with-dbi=${perlPackages.DBI.libPath}"
    "--with-dbd-sqlite=${perlPackages.DBD-SQLite.libPath}"
    "--with-www-curl=${perlPackages.WWW-Curl.libPath}"
    "--disable-init-state"
    "--enable-gc"
  ];

  preBuild = ''
    makeFlagsArray+=("profiledir=$out/etc/profile.d")
  '';

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  meta = with stdenv.lib; {
    description = "Powerful package manager that makes package management reliable and reproducible";
    homepage = http://nixos.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
