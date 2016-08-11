{ stdenv
, config
, fetchFromGitHub
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

, channel

, storeDir ? config.nix.storeDir or "/nix/store"
, stateDir ? config.nix.stateDir or "/nix/var"
}:

let
  source = ((import ./sources.nix {
      inherit
        fetchFromGitHub
        fetchurl;
    })."${channel}");
in
stdenv.mkDerivation rec {
  name = "nix-${source.version}";

  src = source.src;

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

  CXXFLAGS = "-Wno-error=reserved-user-defined-literal";

  configureFlags = [
    "--localstatedir=${stateDir}"
    "--sysconfdir=/etc"
    "--with-store-dir=${storeDir}"
    "--with-dbi=${perlPackages.DBI}/${perl.libPrefix}"
    "--with-dbd-sqlite=${perlPackages.DBDSQLite}/${perl.libPrefix}"
    "--with-www-curl=${perlPackages.WWWCurl}/${perl.libPrefix}"
    "--disable-init-state"
    "--enable-gc"
  ];

  preBuild = ''
    makeFlagsArray+=("profiledir=$out/etc/profile.d")
  '';

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  doInstallCheck = false;

  outputs = [
    "out"
    "doc"
  ];

  crossAttrs = {
    postUnpack = ''
      export CPATH="${bzip2.crossDrv}/include"
      export NIX_CROSS_LDFLAGS="-L${bzip2.crossDrv}/lib -rpath-link ${bzip2.crossDrv}/lib $NIX_CROSS_LDFLAGS"
    '';

    configureFlags = ''
      --with-store-dir=${storeDir} --localstatedir=${stateDir}
      --with-dbi=${perlPackages.DBI}/${perl.libPrefix}
      --with-dbd-sqlite=${perlPackages.DBDSQLite}/${perl.libPrefix}
      --with-www-curl=${perlPackages.WWWCurl}/${perl.libPrefix}
      --disable-init-state
      --enable-gc
    '' + stdenv.lib.optionalString (
          stdenv.cross ? nix && stdenv.cross.nix ? system
      ) ''
      --with-system=${stdenv.cross.nix.system}
    '';

    doInstallCheck = false;
  };

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
