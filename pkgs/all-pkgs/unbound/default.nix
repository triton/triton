{ stdenv
, fetchurl

, expat
, fstrm
, libevent
, openssl
, protobuf-c
}:

stdenv.mkDerivation rec {
  name = "unbound-${version}";
  version = "1.5.9";

  src = fetchurl {
    url = "https://unbound.net/downloads/${name}.tar.gz";
    sha256 = "01328cfac99ab5b8c47115151896a244979e442e284eb962c0ea84b7782b6990";
  };

  buildInputs = [
    expat
    fstrm
    libevent
    openssl
    protobuf-c
  ];

  configureFlags = [
    "--with-ssl=${openssl}"
    "--with-libexpat=${expat}"
    "--with-libevent=${libevent}"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--enable-pie"
    "--enable-relro-now"
    "--enable-dnstap"
    "--with-dnstap-socket-path=/run/dnstap.sock"
  ];

  preInstall = ''
    installFlagsArray+=("configfile=$out/etc/unbound/unbound.conf")
  '';

  meta = with stdenv.lib; {
    description = "Validating, recursive, and caching DNS resolver";
    homepage = http://www.unbound.net;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
