{ stdenv
, fetchurl
, intltool
, lib

, libxml2
, gcr
, glib
, json-glib
#, gnome-online-accounts
, gobject-introspection
, liboauth
, libsoup
, openssl
, p11-kit
, vala
}:

let
  inherit (lib)
    boolEn;

  versionMajor = "0.17";
  versionMinor = "9";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "libgdata-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgdata/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "85c4f7674c0098ffaf060ae01b6b832cb277b3673d54ace3bdedaad6b127453a";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    gcr
    glib
    #gnome-online-accounts
    gobject-introspection
    json-glib
    liboauth
    libsoup
    libxml2
    openssl
    p11-kit
    vala
  ];

  configureFlags = [
    "--enable-gnome"
    # Remove dependency on webkit
    #"--${boolEn (gnome-online-accounts != null)}-goa"
    "--disable-goa"
    "--disable-always-build-tests"
    "--disable-installed-tests"
    "--enable-nls"
    "--disable-code-coverage"
    "--enable-compile-warnings"
    "--disable-Werror"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgdata/${versionMajor}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GLib library for online service APIs using the GData protocol";
    homepage = https://wiki.gnome.org/Projects/libgdata;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
