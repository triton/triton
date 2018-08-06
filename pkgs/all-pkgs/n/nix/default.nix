{ stdenv
, config
, fetchTritonPatch
, fetchurl
, lib
, perl

, boehm-gc
, bzip2
, curl
, libseccomp
, libsodium
, openssl
, perlPackages
, sqlite
, xz

, storeDir ? config.nix.storeDir or "/nix/store"
, stateDir ? config.nix.stateDir or "/nix/var"
}:

let
  version = "1.11.15";
in
stdenv.mkDerivation rec {
  name = "nix-${version}";

  src = fetchurl {
    url = "https://nixos.org/releases/nix/${name}/${name}.tar.xz";
    multihash = "QmQZZDokYTPBgsgt59BxAsHyUMrXeJqLzkADd7wq6MQq38";
    hashOutput = false;
    sha256 = "d20f20e45d519f54fae5c61d55eadcf53e6d7cdbde9870eeec80d499f9805165";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    curl
    libseccomp
    libsodium
    openssl
    sqlite
    xz
  ];

  propagatedBuildInputs = [
    boehm-gc
  ];

  patches = [
    (fetchTritonPatch {
      rev = "3ff52684b7fa197b14157fc9f90e420dfdb80a33";
      file = "n/nix/ca-certs.patch";
      sha256 = "c6ba735c84d68ddac924d56fe4ccfd8ad9630857fc44c6b20d30b1385d127701";
    })
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

  passthru = {
    inherit
      version;
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = map (x: "${x}.sha256") src.urls;
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Package manager that makes packages reproducible";
    homepage = https://nixos.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
