{ stdenv
, fetchurl

, libsodium
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dnscrypt-proxy-1.9.1";

  src = fetchurl {
    url = "https://download.dnscrypt.org/dnscrypt-proxy/${name}.tar.gz";
    multihash = "Qmc6JoKRAGixEN5UV9mAeoPD9sQwkXcEcr1nSGcV1eUTUA";
    hashOutput = false;
    sha256 = "3a319e8bfff5ac15a1c5a80af71755380b1fb869cb8fd86b33b7ed928db65195";
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
