{ stdenv
, fetchurl
, lib
, util-macros

, zlib
}:

stdenv.mkDerivation rec {
  name = "libpciaccess-0.14";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "3df543e12afd41fea8eac817e48cbfde5aed8817b81670a4e9e493bb2f5bf2a4";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    zlib
  ];

  configureFlags = [
    "--disable-linux-rom-fallback"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Adam Jackson
        "995E D5C8 A613 8EB0 961F  1847 4C09 DD83 CAAA 50B2"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Generic PCI access library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
