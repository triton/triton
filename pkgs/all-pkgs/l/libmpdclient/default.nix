{ stdenv
, fetchurl
, lib
, meson
, ninja
}:

let
  versionMajor = "2";
  versionMinor = "13";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "libmpdclient-${version}";

  src = fetchurl {
    url = "https://www.musicpd.org/download/libmpdclient/${versionMajor}/"
        + "${name}.tar.xz";
    multihash = "QmPGLstus9AbHLBTqbMP3eGH55eCt5Nn22MrAwEcWEBKGY";
    hashOutput = false;
    sha256 = "5115bd52bc20a707c1ecc7487e6389c17305348e2132a66cf767c62fc55ed45d";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  mesonFlags = [
    "-Dtcp=true"
    "-Ddocumentation=false"
    "-Dtest=false"
  ];

  passthru = {
    inherit
      versionMajor
      versionMinor;

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "0392 335A 7808 3894 A430  1C43 236E 8A58 C6DB 4512";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Client library for MPD (music player daemon)";
    homepage = http://www.musicpd.org/libs/libmpdclient/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
