{ stdenv
, fetchurl

, c-ares
, libevent
, openssl
, pam
}:

let
  version = "1.8.1";
in
stdenv.mkDerivation rec {
  name = "pgbouncer-${version}";

  src = fetchurl rec {
    url = "https://pgbouncer.github.io/downloads/files/${version}/${name}.tar.gz";
    sha256Url = "${url}.sha256";
    sha256 = "fa8bde2a2d2c8c80d53a859f8e48bc6713cf127e31c77d8f787bbc1d673e8dc8";
  };

  buildInputs = [
    libevent
    openssl
    pam
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-cares=${c-ares}"
    "--with-pam"
    "--with-root-ca-file=/etc/ssl/certs/ca-certificates.crt"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
