{ stdenv
, fetchurl

, libbsd
, libressl
}:

let
  version = "0.1.16";

  fileUrls = [
    "https://kristaps.bsd.lv/acme-client/snapshots/acme-client-portable-${version}"
  ];
in
stdenv.mkDerivation rec {
  name = "acme-client-${version}";

  src = fetchurl {
    urls = map (n: "${n}.tgz") fileUrls;
    multihash = "QmQJjHnrsTg1JedURo5XAGnJcujD5oxgGnxP78ae3Na8mA";
    hashOutput = false;
    sha256 = "e9e705a362f6d450f4a229b34199cfb8022b8268cb86accf75d6b5b0c62a0003";
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
