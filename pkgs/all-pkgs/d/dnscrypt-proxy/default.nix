{ stdenv
, fetchurl

, libsodium
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dnscrypt-proxy-1.8.1";

  src = fetchurl {
    url = "https://download.dnscrypt.org/dnscrypt-proxy/${name}.tar.gz";
    multihash = "QmPw9pF3E91kRCXvm1Mo6gEaAqn8ETEessnwAbYYaHPSkS";
    hashOutput = false;
    sha256 = "5cad1d2357852dc16957085e7a9b32384fb9b95c609e185b7ae1a3959fc13769";
  };

  buildInputs = [
    libsodium
    systemd_lib
  ];

  configureFlags = [
    "--enable-plugins"
    "--with-systemd"
  ];

  passthru = rec {
    srcVerification = fetchurl {
      failEarly = true;
      minisignUrls = map (n: "${n}.minisig") src.urls;
      minisignPub = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A tool for securing communications between a client & a DNS resolver";
    homepage = http://dnscrypt.org/;
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
