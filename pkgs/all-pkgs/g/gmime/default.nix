{ stdenv
, fetchurl
, lib

, glib
, gobject-introspection
, libgpg-error
, zlib
}:

let
  inherit (lib)
    boolEn;

  channel = "3.2";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "gmime-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gmime/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "75ec6033f9192488ff37745792c107b3d0ab0a36c2d3e4f732901a771755d7e0";
  };

  buildInputs = [
    glib
    gobject-introspection
    libgpg-error
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-profiling"
    "--disable-warnings"
    "--disable-glibtest"
    "--enable-largefile"
    "--${boolEn (libgpg-error != null)}-crypto"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-vala"
    "--disable-coverage"
    #--with-libiconv=
    #--with-gpgme-prefix=
    #--with-libidn=
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gmime/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A C/C++ library for manipulating MIME messages";
    homepage = http://spruce.sourceforge.net/gmime/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
