{ stdenv
, config
, fetchurl
, lib

, aws-sdk-cpp
, busybox
, boehm-gc
, brotli
, bzip2
, curl
, libseccomp
, libsodium
, openssl
, sqlite
, xz

, storeDir ? config.nix.storeDir or "/nix/store"
}:

stdenv.mkDerivation rec {
  name = "nix-2.0.2";

  src = fetchurl {
    url = "https://nixos.org/releases/nix/${name}/${name}.tar.xz";
    multihash = "QmecUivPEb8TNiXz64tE7Q2rNtK6m8DE5fyXGMasRdUGHT";
    sha256 = "2d2984410f73d759485526e594ce41b9819fafa4676f4f85a93dbdd5352a1435";
  };

  buildInputs = [
    #aws-sdk-cpp
    boehm-gc
    brotli
    bzip2
    curl
    libseccomp
    libsodium
    openssl
    sqlite
    xz
  ];

  # Make sure we have a working busybox sh
  postPatch = ''
    '${busybox}'/bin/busybox sh --help 2>&1 | grep -q 'Usage: sh'
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-gc"
    "--disable-init-state"
    "--with-store-dir=${storeDir}"
    "--with-sandbox-shell=${busybox}/bin/busybox"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  passthru = {
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
