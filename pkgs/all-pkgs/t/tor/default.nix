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
  name = "tor-0.2.8.6";

  src = fetchurl {
    url = "https://www.torproject.org/dist/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "3dc9fc02f7cd22ed5fce707e0d9b26a72b1bd0976766a804cb13078d32e3ab5a";
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
      pgpKeyFingerprint = "B35B F85B F194 89D0 4E28  C33C 2119 4EBB 1657 33EA";
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
