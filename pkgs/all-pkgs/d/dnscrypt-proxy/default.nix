{ stdenv
, fetchurl

, libsodium
, systemd_lib
}:

let
  version = "1.9.4";
in
stdenv.mkDerivation rec {
  name = "dnscrypt-proxy-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/jedisct1/dnscrypt-proxy/releases/download/${version}/${name}.tar.bz2"
      "https://download.dnscrypt.org/dnscrypt-proxy/${name}.tar.bz2"
    ];
    multihash = "QmWpcCZPPAkcC4i78e5wFpeF3q5MwyB9JbTrJkad5Vxmtu";
    hashOutput = false;
    sha256 = "fdf4a708e7922e13b14555f315ca8d5361aec89b0595b06fdbbcaacfa4e6f11e";
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
