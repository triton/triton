{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfpx-1.3.1-8";

  src = fetchurl {
    url = "mirror://imagemagick/delegates/${name}.tar.xz";
    multihash = "QmaL3ZGmVcTuPcr9y9RSWXAPNi8ZtmwRCCodedNEEYP6uw";
    hashOutput = false;
    sha256 = "654eb938f810fcf032c76e5e339038787c520733a39e088544aaa7bcc4e3703b";
  };

  configureFlags = [
    "--disable-maintainer-mode"
  ];

  CXXFLAGS = "-std=c++11";

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "D827 2EF5 1DA2 23E4 D05B  4669 89AB 63D4 8277 377A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A library for manipulating FlashPIX images";
    homepage = http://www.imagemagick.org;
    license = licenses.free; # Flashpix
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
