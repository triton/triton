{ stdenv
, fetchurl
, lib
, util-macros

, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libxshmfence-1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b884300d26a14961a076fbebc762a39831cb75f92bed5ccf9836345b459220c7";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    xorgproto
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Matt Turner
        "3BB6 39E5 6F86 1FA2 E865  0569 0FDD 682D 974C A72A"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library that exposes a event API on top of Linux futexes";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
