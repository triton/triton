{ stdenv
, fetchurl
, intltool

, gegl
, glib
, json-c
}:

let
  version = "1.3.0-beta.1";
in
stdenv.mkDerivation rec {
  name = "libmypaint-${version}";

  src = fetchurl {
    url = "https://github.com/mypaint/libmypaint/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d39138b21b9057376138e64f09f4c4741a14a7baed71d6f0ba9bc2504d69f9ee";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    gegl
    glib
    json-c
  ];

  configureFlags = [
    "--enable-openmp"
    "--enable-i18n"
    "--with-glib"
    "--enable-gegl"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
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
