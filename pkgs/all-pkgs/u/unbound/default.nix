{ stdenv
, fetchurl

, expat
, fstrm
, hiredis
, libevent
, libsodium
, openssl
, protobuf-c
, systemd_lib
}:

let
  tarballUrls = version: [
    "https://unbound.net/downloads/unbound-${version}.tar.gz"
  ];

  version = "1.8.3";
in
stdenv.mkDerivation rec {
  name = "unbound-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmQSFLPRjbthLvEXFaYCV4N9q8cCFuANDBTVUBvF1UaRwh";
    hashOutput = false;
    sha256 = "2b692b8311edfad41e7d0380aac34576060d4176add81dc5db419c79b2a4cecc";
  };

  buildInputs = [
    expat
    fstrm
    hiredis
    libevent
    libsodium
    openssl
    protobuf-c
    systemd_lib
  ];

  # 1.8.0 broke autoconf pkg-config detection so we have to set
  # the location of the binary manually
  PKG_CONFIG = "pkg-config";

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--enable-pie"
    "--enable-relro-now"
    "--enable-subnet"
    "--enable-tfo-client"
    "--enable-tfo-server"
    "--enable-systemd"
    "--enable-dnstap"
    "--enable-dnscrypt"
    "--enable-cachedb"
    "--enable-ipsecmod"
    "--with-ssl=${openssl}"
    "--with-libexpat=${expat}"
    "--with-libevent=${libevent}"
    "--with-libhiredis=${hiredis}"
    "--with-dnstap-socket-path=/run/dnstap.sock"
    "--with-pthreads"
  ];

  preInstall = ''
    installFlagsArray+=("configfile=$out/etc/unbound/unbound.conf")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.8.3";
      outputHash = "2b692b8311edfad41e7d0380aac34576060d4176add81dc5db419c79b2a4cecc";
      inherit (src)
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "EDFA A3F2 CA4E 6EB0 5681  AF8E 9F6F 1C2D 7E04 5F8D";
      };
    };
  };

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
