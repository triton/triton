{ stdenv
, docbook-xsl
, fetchurl
, intltool
, lib
, libxslt
#, meson
#, ninja

, glib
, gobject-introspection
, libgcrypt
, vala
}:

let
  inherit (lib)
    boolEn;

  channel = "0.18";
  version = "${channel}.8";
in
stdenv.mkDerivation rec {
  name = "libsecret-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsecret/${channel}/${name}.tar.xz";
    sha256 = "3bfa889d260e0dbabcf5b9967f2aae12edcd2ddc9adc365de7a5cc840c311d15";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    docbook-xsl
    #meson
    #ninja
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    libgcrypt
  ];

  #mesonFlags = [
  #  "-Dvapi=${boolTf (vala != null)}"
  #  "-Dgtk_doc=false"
  #];

  configureFlags = [
    "--enable-introspection"
    "--enable-manpages"
    "--${boolEn (vala != null)}-vala"
    "--enable-gcrypt"
    "--with-libgcrypt-prefix=${libgcrypt}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (u: lib.replaceStrings ["tar.xz"] ["sha256sum"] u) src.urls;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GObject library for the freedesktop.org Secret Service API";
    homepage = https://wiki.gnome.org/Projects/Libsecret;
    license = with licenses; [
      #apache20
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
