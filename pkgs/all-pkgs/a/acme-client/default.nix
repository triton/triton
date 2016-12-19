{ stdenv
, fetchurl

, libbsd
, libressl
}:

let
  version = "0.1.15";

  fileUrls = [
    "https://kristaps.bsd.lv/acme-client/snapshots/acme-client-portable-${version}"
  ];
in
stdenv.mkDerivation rec {
  name = "acme-client-${version}";

  src = fetchurl {
    urls = map (n: "${n}.tgz") fileUrls;
    multihash = "QmUWFZNh2d5eQvu7qArRrADMea5wHkTaJew1CuYAHTcUat";
    hashOutput = false;
    sha256 = "910f4ffab4aea2dc9563405aa6a53e85d00166a020c74c28d719f290c610e71e";
  };

  buildInputs = [
    libbsd
    libressl
  ];

  postPatch = ''
    set -x
    grep -q '/etc/ssl/cert.pem' http.c
    sed -i 's,/etc/ssl/cert.pem,/etc/ssl/certs/ca-certificates.crt,g' http.c
    set +x
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha512Urls = map (n: "${n}.sha512") fileUrls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
