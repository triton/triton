{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, acl

, version
}:

let
  inherit (lib)
    optionals
    versionOlder;

  tarballUrls = version: [
    "mirror://gnu/tar/tar-${version}.tar.xz"
  ];

  sha256s = {
    "1.29" = "402dcfd0022fd7a1f2c5611f5c61af1cd84910a760a44a688e18ddbff4e9f024";
    "1.30" = "f1bf92dbb1e1ab27911a861ea8dde8208ee774866c46c0bb6ead41f4d1f4d2d3";
  };
in
stdenv.mkDerivation rec {
  name = "gnutar-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = sha256s."${version}";
  };

  buildInputs = [
    acl
  ];

  patches = optionals (versionOlder version "1.30") [
    (fetchTritonPatch {
      rev = "dc35113b79d1abbcf4d498e7ac2d469e1787cf0c";
      file = "gnutar/fix-longlink.patch";
      sha256 = "5b8a6c325cdaf83588fb87778328b47978db33230c44f24b4a909bc9306d2d86";
    })
    (fetchTritonPatch {
      rev = "ef4ae4eb246abb08e9cb89174dd3854f7e3e3409";
      file = "g/gnutar/CVE-2016-6321.patch";
      sha256 = "53476b4482044a244a2858b7706ec91cacfe7083f27331b2158eda731b5f455a";
    })
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.30";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "325F 650C 4C2B 6AD5 8807  327A 3602 B07F 55D0 C732";
      inherit (src) outputHashAlgo;
      outputHash = "f1bf92dbb1e1ab27911a861ea8dde8208ee774866c46c0bb6ead41f4d1f4d2d3";
    };
  };

  meta = with lib; {
    homepage = http://www.gnu.org/software/tar/;
    description = "GNU implementation of the `tar' archiver";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}
