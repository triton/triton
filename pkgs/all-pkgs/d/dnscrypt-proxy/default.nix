{ stdenv
, fetchurl

, libsodium
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dnscrypt-proxy-1.7.0";

  src = fetchurl {
    url = "https://download.dnscrypt.org/dnscrypt-proxy/${name}.tar.bz2";
    sha256 = "1daf77df9092491ea0b5176ec4b170f7b0645f97b62d1a50412a960656b482e3";
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
