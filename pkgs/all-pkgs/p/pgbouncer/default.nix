{ stdenv
, fetchurl

, c-ares
, libevent
, openssl_1-0-2
}:

let
  version = "1.7.2";
in
stdenv.mkDerivation rec {
  name = "pgbouncer-${version}";

  src = fetchurl rec {
    url = "https://pgbouncer.github.io/downloads/files/${version}/${name}.tar.gz";
    sha256Url = "${url}.sha256";
    sha256 = "de36b318fe4a2f20a5f60d1c5ea62c1ca331f6813d2c484866ecb59265a160ba";
  };

  buildInputs = [
    libevent
    openssl_1-0-2
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-cares=${c-ares}"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
