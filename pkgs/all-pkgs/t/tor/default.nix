{ stdenv
, fetchurl
, perl

, libcap
, libevent
, libscrypt
, libseccomp
, libsodium
, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "tor-0.2.9.8";

  src = fetchurl {
    url = "https://www.torproject.org/dist/${name}.tar.gz";
    hashOutput = false;
    sha256 = "fbdd33d3384574297b88744622382008d1e0f9ddd300d330746c464b7a7d746a";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    libcap
    libevent
    libscrypt
    libseccomp
    libsodium
    openssl
    zlib
  ];

  postPatch = ''
    # Remove donna curve25519
    sed -i 's,"x$tor_cv_can_use_curve25519_donna_c64","xno",g' configure
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-unittests"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        "B35B F85B F194 89D0 4E28  C33C 2119 4EBB 1657 33EA"
        "2133 BC60 0AB1 33E1 D826  D173 FE43 009C 4607 B1FB"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
