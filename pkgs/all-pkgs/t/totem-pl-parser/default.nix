{ stdenv
, fetchurl
, gettext
, intltool
, lib

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
  inherit (lib)
    boolEn
    boolString
    boolWt;

  sources = {
    "3.10" = {
      version = "3.10.8";
      sha256 = "ffc50a0713d5f3049912545169eea7d367483b2c4a868032940516ed1e78dd2b";
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
    intltool
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

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-gmime-i-know-what-im-doing"
    # TODO: quvi support
    "--disable-quvi"
    "--${boolEn (libarchive != null)}-libarchive"
    "--${boolEn (libgcrypt != null)}-libgcrypt"
    "--disable-debug"
    "--enable-cxx-warnings"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-code-coverage"
    "--${boolWt (libgcrypt != null)}-libgcrypt-prefix${
      boolString (libgcrypt != null) "=${libgcrypt}" ""}"
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
