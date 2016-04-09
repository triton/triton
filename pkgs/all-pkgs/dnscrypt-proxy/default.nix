{ stdenv
, fetchurl

, libsodium
, systemd_lib
}:

let
  baseUrl = "https://download.dnscrypt.org/dnscrypt-proxy";
in

stdenv.mkDerivation rec {
  name = "dnscrypt-proxy-1.6.1";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.bz2";
    sha256 = "895ac36f5d4898dabf0ed65e0a579d0aa4d9a9be9cca4dca7b573a0ff170919a";
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
    nextName = "dnscrypt-proxy-1.6.1";

    srcVerified = fetchurl {
      failEarly = true;
      url = "${baseUrl}/${nextName}.tar.bz2";
      minisignUrl = "${baseUrl}/${nextName}.tar.bz2.minisig";
      minisignPub = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      sha256 = "895ac36f5d4898dabf0ed65e0a579d0aa4d9a9be9cca4dca7b573a0ff170919a";
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
