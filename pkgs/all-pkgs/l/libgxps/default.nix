{ stdenv
, fetchurl
, lib
, meson
, ninja

, cairo
, glib
, freetype
, gobject-introspection
, lcms2
, libarchive
, libjpeg
, libpng
, libtiff
, zlib

, channel
}:

let
  sources = {
    "0.3" = {
      version = "0.3.0";
      sha256 = "412b1343bd31fee41f7204c47514d34c563ae34dafa4cc710897366bd6cd0fae";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgxps-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgxps/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    cairo
    glib
    freetype
    gobject-introspection
    lcms2
    libarchive
    libjpeg
    libpng
    libtiff
    zlib
  ];

  mesonFlags = [
    "-Denable-test=false"
    "-Denable-gtk-doc=false"
    "-Denable-man=false"
    "-Ddisable-introspection=false"
    "-Dwith-liblcms2=true"
    "-Dwith-libjpeg=true"
    "-Dwith-libtiff=true"
  ];

  postInstall = /* pkgconf can't parse >= in Requires if it is not surrounded
                   by spaces */ ''
    sed -i $out/lib/pkgconfig/libgxps.pc \
      -e 's/>=/ >= /g'
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgxps/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library for handling and rendering XPS documents";
    homepage = https://wiki.gnome.org/Projects/libgxps;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
