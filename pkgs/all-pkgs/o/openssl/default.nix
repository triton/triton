{ stdenv
, fetchTritonPatch
, fetchurl
, perl

, cryptodevHeaders
, zlib

, channel ? "1.0.2"
}:

let
  sources = {
    "1.0.2" = {
      version = "1.0.2j";
      sha256 = "e7aff292be21c259c6af26469c7a9b3ba26e9abaaffd325e3dccc9785256c431";
      patches = [
        (fetchTritonPatch {
           rev = "f2bfa2d2db51744e6fcb5677543b3bce8504bf82";
           file = "openssl/use-etc-ssl-certs.patch";
           sha256 = "537e96a5949507706efe3607093f3f8cbfd7e8228a734bb6a766ff828c17117d";
        })
      ];
    };
    "1.1.0" = {
      version = "1.1.0a";
      sha256 = "c2e696e34296cde2c9ec5dcdad9e4f042cd703932591d395c389de488302442b";
      patches = [
        (fetchTritonPatch {
          rev = "caf82b1cce7289f53531e0ae4775fe0f4aa417a9";
          file = "openssl/use-etc-ssl-certs.patch";
          sha256 = "59d8c72f5ec030d26ef75e6da199da6a8cba5ed9c05c66296c8a0ea27bf63048";
        })
      ];
    };
  };

  inherit (stdenv.lib)
    optionals
    versionOlder;

  inherit (sources."${channel}")
    patches
    sha256
    version;
in
stdenv.mkDerivation rec {
  name = "openssl-${version}";

  src = fetchurl {
    urls = [
      "https://www.openssl.org/source/${name}.tar.gz"
      "http://openssl.linux-mirror.org/source/${name}.tar.gz"
    ];
    hashOutput = false;
    inherit sha256;
  };

  inherit patches;

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    cryptodevHeaders
    zlib
  ];

  configureScript = "./config";

  configureFlags = [
    "shared"
    # "sctp"  TODO: Find needed headers
    "zlib"
    "--libdir=lib"
    "--openssldir=/etc/ssl"
    # TODO: Enable krb5
    "disable-ssl3"
  ] ++ optionals (versionOlder version "1.1.0") [
    "disable-ssl2"
  ];

  preBuild = ''
    # We don't want to build static libraries
    sed -i 's, libcrypto.a,,g; s, libssl.a,,g' Makefile

    makeFlagsArray+=("MANDIR=$out/share/man")
    installFlagsArray+=("OPENSSLDIR=$out/etc/ssl")
  '';

  # Parallel installing is broken in OpenSSL, it creates invaild shared objects.
  parallelInstall = false;

  preFixup = ''
    # remove dependency on Perl at runtime
    rm -r $out/etc/ssl/misc $out/bin/c_rehash

    # Remove unused stuff
    rmdir $out/etc/ssl/{certs,private}
  '';

  disallowedReferences = [ perl ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      pgpKeyFingerprints = [
        "EFC0 A467 D613 CB83 C7ED  6D30 D894 E2CE 8B3D 79F5"
        "8657 ABB2 60F0 56B1 E519  0839 D9C4 D26D 0E60 4491"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.openssl.org/;
    description = "A cryptographic library that implements the SSL and TLS protocols";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
