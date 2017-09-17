{ stdenv
, fetchurl
, gettext
, intltool
, lib
, meson
, ninja

, file
, glib
, gmime
, gobject-introspection
, libarchive
, libgcrypt
, libsoup
, libxml2

, channel
}:

let
  sources = {
    "3.26" = {
      version = "3.26.0";
      sha256 = "f153a53391e9b42fed5cb6ce62322a58e323fde6ec4a54d8ba4d376cf4c1fbcb";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "totem-pl-parser-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/totem-pl-parser/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    file
    glib
    gmime
    gobject-introspection
    libarchive
    libgcrypt
    libsoup
    libxml2
  ];

  mesonFlags = [
    "-Ddisable-gmime-i-know-what-im-doing=false"
    "-Denable-quvi=no"
    "-Denable-libarchive=yes"
    "-Denable-libgcrypt=yes"
    "-Denable-gtk-doc=false"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/totem-pl-parser/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GObject library to parse and save playlist formats";
    homepage = https://wiki.gnome.org/Apps/Videos;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
