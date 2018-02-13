{ stdenv
, fetchurl
, lib
, meson
, ninja
}:

let
  channel = "2";
  version = "${channel}.14";
in
stdenv.mkDerivation rec {
  name = "libmpdclient-${version}";

  src = fetchurl {
    url = "https://www.musicpd.org/download/libmpdclient/${channel}/"
        + "${name}.tar.xz";
    multihash = "QmYLvsgQCNte2YzyocgNX9iPxyoi1EK3B55sY1Z1jXzY1H";
    hashOutput = false;
    sha256 = "0a84e2791bfe3077cf22ee1784c805d5bb550803dffe56a39aa3690a38061372";
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
