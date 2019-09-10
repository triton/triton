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
      version = "1.0.2t";
      multihash = "QmQFUWDeTD2ojLiEftQAimqzeVsviEgMKAdaGbFgShNUc4";
      sha256 = "14cb464efe7ac6b54799b34456bd69558a749a4931ecfd9cf9f71d7881cac7bc";
      patches = [
        (fetchTritonPatch {
           rev = "f2bfa2d2db51744e6fcb5677543b3bce8504bf82";
           file = "openssl/use-etc-ssl-certs.patch";
           sha256 = "537e96a5949507706efe3607093f3f8cbfd7e8228a734bb6a766ff828c17117d";
        })
      ];
    };
    "1.1.1" = {
      version = "1.1.1d";
      multihash = "QmcuVw5cVmYBMS6Ycvh7bPpTZRXCyVASLhP15NkALu8PEK";
      sha256 = "1e3a91bc1f9dfce01af26026f856e064eab4c8ee0a8f457b5ae30b40b8b711f2";
      patches = [
        (fetchTritonPatch {
          rev = "29569cdc2793ba0e4902c2134fa3f3bbe9eb6a9f";
          file = "o/openssl/use-etc-ssl-certs.patch";
          sha256 = "db8dee66e41ea0a0186d4194d782f490f7222e9bce79f5496a578c1ed444b158";
        })
      ];
    };
  };

  inherit (stdenv.lib)
    optionals
    optionalString
    versionAtLeast
    versionOlder;

  inherit (sources."${channel}")
    multihash
    patches
    sha256
    version;

  tarballUrls = version: [
    "https://www.openssl.org/source/openssl-${version}.tar.gz"
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

  preConfigure = optionalString (versionAtLeast version "1.1.1") ''
    sed -i 's,/usr/bin/env,env,g' config
  '';

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
  installParallel = false;

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
      urls = tarballUrls "1.1.1a";
      inherit (src)
        outputHashAlgo;
      outputHash = "fc20130f8b7cbd2fb918b2f14e2f429e109c31ddd0fb38fc5d71d9ffed3f9f41";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        sha256Urls = map (n: "${n}.sha256") urls;
        pgpKeyFingerprints = [
          "EFC0 A467 D613 CB83 C7ED  6D30 D894 E2CE 8B3D 79F5"
          "8657 ABB2 60F0 56B1 E519  0839 D9C4 D26D 0E60 4491"
          "7953 AC1F BC3D C8B3 B292  393E D5E9 E43F 7DF9 EE8C"
        ];
      };
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
