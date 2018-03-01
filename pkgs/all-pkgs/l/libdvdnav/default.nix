{ stdenv
, fetchurl
, lib

, libdvdread
}:

let
  version = "6.0.0";
in
stdenv.mkDerivation rec {
  name = "libdvdnav-${version}";

  src = fetchurl {
    url = "mirror://videolan/libdvdnav/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f0a2711b08a021759792f8eb14bb82ff8a3c929bf88c33b64ffcddaa27935618";
  };

  buildInputs = [
    libdvdread
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # VideoLAN Release Signing Key
        "65F7 C6B4 206B D057 A7EB  7378 7180 713B E58D 1ADC"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library for DVD navigation tools";
    homepage = http://dvdnav.mplayerhq.hu/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
