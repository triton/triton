{ stdenv
, fetchurl
, intltool

, gegl
, glib
, json-c
}:

let
  version = "1.3.0";

  baseUrls = [
    "https://github.com/mypaint/libmypaint/releases/download/v${version}/libmypaint-${version}"
  ];
in
stdenv.mkDerivation rec {
  name = "libmypaint-${version}";

  src = fetchurl {
    urls = map (n: "${n}.tar.xz") baseUrls;
    hashOutput = false;
    sha256 = "6a07d9d57fea60f68d218a953ce91b168975a003db24de6ac01ad69dcc94a671";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    gegl
    glib
    json-c
  ];

  postPatch = ''
    sed -i 's,gegl-0.3,gegl-0.4,' configure gegl/libmypaint-gegl.pc.in
  '';

  configureFlags = [
    "--enable-openmp"
    "--enable-i18n"
    "--with-glib"
    "--enable-gegl"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Urls = map (n: "${n}.sha256.asc") baseUrls;
      pgpKeyFingerprint = "C023 91F4 BBA4 F0E2 B27C  6BFF 6E30 37E1 2878 B299";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
