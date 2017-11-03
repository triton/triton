{ stdenv
, fetchTritonPatch
, fetchurl
, perl

, cryptodev_headers
, zlib

, channel
}:

let
  sources = {
    "1.0.2" = {
      version = "1.0.2m";
      multihash = "QmadqkiZoGyUAULXrX9cQCGRwdbJwTBPRcdEsqQDjTGmUL";
      sha256 = "8c6ff15ec6b319b50788f42c7abc2890c08ba5a1cdcd3810eb9092deada37b0f";
      patches = [
        (fetchTritonPatch {
           rev = "f2bfa2d2db51744e6fcb5677543b3bce8504bf82";
           file = "openssl/use-etc-ssl-certs.patch";
           sha256 = "537e96a5949507706efe3607093f3f8cbfd7e8228a734bb6a766ff828c17117d";
        })
      ];
    };
    "1.1.0" = {
      version = "1.1.0g";
      multihash = "QmQ8QbZm1bENziurKDCYnbq1BJUAjxwaSUaoZWNFyT8hNb";
      sha256 = "de4d501267da39310905cb6dc8c6121f7a2cad45a7707f76df828fe1b85073af";
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
    multihash
    patches
    sha256
    version;

  tarballUrls = version: [
    "https://www.openssl.org/source/openssl-${version}.tar.gz"
    #"http://openssl.linux-mirror.org/source/${name}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "openssl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    inherit multihash sha256;
  };

  inherit patches;

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    cryptodev_headers
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
    makeFlagsArray+=("MANDIR=$out/share/man")
    installFlagsArray+=("OPENSSLDIR=$out/etc/ssl")
  '';

  # Parallel installing is broken in OpenSSL, it creates invaild shared objects.
  parallelInstall = false;

  # If we built shared objects don't include static
  postInstall = ''
    if ls "$out"/lib | grep -q '.so''$'; then
      rm "$out"/lib/*.a
    fi
  '';

  preFixup = ''
    # remove dependency on Perl at runtime
    rm -r $out/etc/ssl/misc $out/bin/c_rehash

    # Remove unused stuff
    rmdir $out/etc/ssl/{certs,private}
  '';

  disallowedReferences = [
    perl
  ];

  passthru = {
    inherit version;
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.1.0g";
      pgpsigUrls = map (n: "${n}.asc") urls;
      sha256Urls = map (n: "${n}.sha256") urls;
      pgpKeyFingerprints = [
        "EFC0 A467 D613 CB83 C7ED  6D30 D894 E2CE 8B3D 79F5"
        "8657 ABB2 60F0 56B1 E519  0839 D9C4 D26D 0E60 4491"
      ];
      inherit (src) outputHashAlgo;
      outputHash = "57be8618979d80c910728cfc99369bf97b2a1abd8f366ab6ebdee8975ad3874c";
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
    priority = 1;  # Let other ssl and passwd impls replace this
  };
}
