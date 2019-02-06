{ stdenv
, fetchurl
, lib

, freeglut
, giflib
, libjpeg
, libpng
, libtiff
, opengl-dummy

, viewer ? false
}:

let
  inherit (lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "libwebp-1.0.2";

  src = fetchurl {
    url = "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${name}.tar.gz";
    sha256 = "3d47b48c40ed6476e8047b2ddb81d93835e0ca1b8d3e8c679afbb3004dd564b1";
  };

  configureFlags = [
    "--enable-threading"
    "--enable-gl"
    "--enable-png"
    "--enable-jpeg"
    "--enable-tiff"
    "--enable-gif"
    # "--enable-aligned"
    # "--enable-swap-16bit-csp"
    # "--enable-experimental"
    "--enable-libwebpmux"
    "--enable-libwebpdemux"
    "--enable-libwebpdecoder"
    "--enable-libwebpextras"
  ];

  buildInputs = [
    giflib
    libjpeg
    libpng
    libtiff
  ] ++ optionals viewer [
    freeglut
    opengl-dummy
  ];

  meta = with lib; {
    description = "Tools and library for the WebP image format";
    homepage = https://developers.google.com/speed/webp/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
