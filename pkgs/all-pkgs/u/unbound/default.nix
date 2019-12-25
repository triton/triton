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

  version = "1.9.6";
in
stdenv.mkDerivation rec {
  name = "unbound-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmRkkhhku1UHwR4s8C8Vp6pvdyAQ9FewWJTUv2HGtYRP4Y";
    hashOutput = false;
    sha256 = "1d98fc6ea99197a20b4a0e540e87022cf523085786e0fc26de6ebb2720f5aaf0";
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
      urls = tarballUrls "1.9.6";
      outputHash = "1d98fc6ea99197a20b4a0e540e87022cf523085786e0fc26de6ebb2720f5aaf0";
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
