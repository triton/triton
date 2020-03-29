{ stdenv
, fetchurl
, lib
, util-macros

, libbsd
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXdmcp-1.1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "20523b44aaa513e17c009e873ad7bbc301507a3224c232610ce2e099011c6529";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libbsd
    xorgproto
  ];

  configureFlags = [
    "--disable-docs"
    "--disable-unit-tests"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Alan Coopersmith
        "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X Display Manager Control Protocol routines";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
