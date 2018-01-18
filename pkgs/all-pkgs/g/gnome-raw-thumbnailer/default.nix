{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, lib

, gdk-pixbuf
, glib
, libopenraw
}:

let
  version = "3.0.0";
in
stdenv.mkDerivation rec {
  name = "gnome-raw-thumbnailer-${version}";

  src = fetchurl {
    url = "https://libopenraw.freedesktop.org/download/raw-thumbnailer-3.0.0.tar.bz2";
    multihash = "";
    hashOutput = false;
    sha256 = "27afbc429f2772d5b9190c5443158ac33352e6bd5fede3aa1a7aa6b5fbb9d253";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    intltool
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    libopenraw
  ];

  patches = [
    (fetchTritonPatch {
      rev = "250b1fa099d47483432ad0df03bf55335cb0072c";
      file = "g/gnome-raw-thumbnailer/gnome-raw-thumbnailer-3.0.0-deprecation-warning.patch";
      sha256 = "dbb494438ac4f19bb05ad87051302f3e20ef2b69491c1694867aa622000d30fc";
    })
    (fetchTritonPatch {
      rev = "250b1fa099d47483432ad0df03bf55335cb0072c";
      file = "g/gnome-raw-thumbnailer/gnome-raw-thumbnailer-3.0.0-fix-downscale.patch";
      sha256 = "f9b841c97fa5d0eaf16f78e6ecfe63ac17f1c9c7aec79005284453388e6f3368";
    })
    (fetchTritonPatch {
      rev = "250b1fa099d47483432ad0df03bf55335cb0072c";
      file = "g/gnome-raw-thumbnailer/gnome-raw-thumbnailer-3.0.0-libopenraw-0.1.patch";
      sha256 = "5a18c7de9f6cf0c849d735a6e0762f63ad6bfdb37a1c3d953bfe65a796412871";
    })
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      # Hubert Figuiere
      pgpKeyFingerprint = "6C44 DB3E 0BF3 EAF5 B433  239A 5FEE 05E6 A56E 15A3";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Thumbnailer for RAW files";
    homepage = https://libopenraw.freedesktop.org/wiki/RawThumbnailer/;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
