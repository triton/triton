{ stdenv
, fetchurl
, gettext
, intltool
, lib

, bzip2
, gdk-pixbuf
, glib
, gobject-introspection
, libxml2
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  sources = {
    "1.14" = {
      version = "1.14.46";
      sha256 = "ea36959b1421fc8e72caa222f30ec3234d0ed95990e2bf28943a85f33eadad2d";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgsf-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgsf/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    bzip2
    gdk-pixbuf
    glib
    gobject-introspection
    libxml2
    zlib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-gir-dir=$out/share/gir-1.0"
      "--with-typelib-dir=$out/lib/girepository-1.0"
    )
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/libgsf/${channel}/"
          + "${name}.sha256sum";
      };
    };
  };

  meta = with lib; {
    description = "GNOME's Structured File Library";
    homepage = https://www.gnome.org/projects/libgsf;
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
