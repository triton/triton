{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "videoproto-2.3.3";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "c7803889fd08e6fcaf7b68cc394fb038b2325d1f315e571a6954577e07cca702";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
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
        "DD38 563A 8A82 2453 7D1F  90E4 5B8A 2D50 A0EC D0D3"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
