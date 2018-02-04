{ stdenv
, fetchurl

, openssl
}:

let
  tarballUrls = version: [
    "https://libbsd.freedesktop.org/releases/libbsd-${version}.tar.xz"
  ];

  version = "0.8.7";
in
stdenv.mkDerivation rec {
  name = "libbsd-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmYiTPhjFUFEsAus2s4ZWDgCKjFLsBQ7iinTqHNpj1xKPY";
    hashOutput = false;
    sha256 = "f548f10e5af5a08b1e22889ce84315b1ebe41505b015c9596bad03fd13a12b31";
  };

  buildInputs = [
    openssl
  ];

  postPatch = ''
    sed \
      -e "s,/usr,$out,g" \
      -e 's,{exec_prefix},{prefix},g' \
      -i Makefile.in
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.8.7";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "4F3E 74F4 3605 0C10 F569  6574 B972 BF3E A4AE 57A3";
      inherit (src) outputHashAlgo;
      outputHash = "f548f10e5af5a08b1e22889ce84315b1ebe41505b015c9596bad03fd13a12b31";
    };
  };

  meta = with stdenv.lib; {
    description = "Common functions found on BSD systems";
    homepage = http://libbsd.freedesktop.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
