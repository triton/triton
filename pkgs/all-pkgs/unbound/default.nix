{ stdenv
, fetchurl

, expat
, libevent
, openssl
}:

stdenv.mkDerivation rec {
  name = "unbound-${version}";
  version = "1.5.7";

  src = fetchurl {
    url = "http://unbound.net/downloads/${name}.tar.gz";
    sha256 = "1a0wfgp6wqpf7cxlcbprqhnjx6z9ywf0rhrpcf7x98l1mbjqh82b";
  };

  buildInputs = [
    expat
    libevent
    openssl
  ];

  configureFlags = [
    "--with-ssl=${openssl}"
    "--with-libexpat=${expat}"
    "--with-libevent=${libevent}"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--enable-pie"
    "--enable-relro-now"
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
      i686-linux
      ++ x86_64-linux;
  };
}
