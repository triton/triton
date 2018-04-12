{ stdenv
, docbook-xsl
, fetchurl
, intltool
, lib
, libxslt

, glib
, gobject-introspection
, libgcrypt
, vala
}:

let
  inherit (lib)
    boolEn;

  channel = "0.18";
  version = "${channel}.6";
in
stdenv.mkDerivation rec {
  name = "libsecret-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsecret/${channel}/${name}.tar.xz";
    sha256 = "5efbc890ba41a323ffe0599cd260fd12bd8eb62a04aa1bd1b2762575d253d66f";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    docbook-xsl
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    libgcrypt
  ];

  configureFlags = [
    "--enable-introspection"
    "--enable-manpages"
    "--${boolEn (vala != null)}-vala"
    "--enable-gcrypt"
    "--disable-debug"
    "--disable-coverage"
    "--with-libgcrypt-prefix=${libgcrypt}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libsecret/"
        + "${channel}/${name}.sha256sum";
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
