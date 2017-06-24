{ stdenv
, fetchurl
, lib

, libsodium
, systemd_lib
}:

let
  version = "1.9.5";
in
stdenv.mkDerivation rec {
  name = "dnscrypt-proxy-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/jedisct1/dnscrypt-proxy/releases/download/${version}/${name}.tar.bz2"
      "https://download.dnscrypt.org/dnscrypt-proxy/${name}.tar.bz2"
    ];
    multihash = "QmRCSZZ2wVLtYtvsJk27dtAhfWAqM5RRKBZXJorkpdT5VC";
    hashOutput = false;
    sha256 = "e89f5b9039979ab392302faf369ef7593155d5ea21580402a75bbc46329d1bb6";
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

  meta = with lib; {
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
