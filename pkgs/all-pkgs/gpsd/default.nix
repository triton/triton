{ stdenv
, fetchurl
, scons

, ncurses
}:

stdenv.mkDerivation rec {
  name = "gpsd-3.16";

  src = fetchurl {
    url = "mirror://savannah/gpsd/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "03579af13a4d3fe0c5b79fa44b5f75c9f3cac6749357f1d99ce5d38c09bc2029";
  };

  nativeBuildInputs = [
    scons
  ];

  buildInputs = [
    ncurses
  ];

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "4187 6B2F 5794 63A4 9984  3D1D ECC8 208F 8C6C 738D";
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  parallelBuild = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
