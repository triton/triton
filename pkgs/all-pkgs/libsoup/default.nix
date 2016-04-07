{ stdenv
, fetchurl
, gettext
, intltool
, python

, glib
, glib-networking
, gobject-introspection
, libxml2
, sqlite
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "libsoup-${version}";
  versionMajor = "2.54";
  versionMinor = "0.1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsoup/${versionMajor}/${name}.tar.xz";
    sha256 = "ade4920166bd036e8890d04acdc135686d877670953949fa6245797c906e38e0";
  };

  nativeBuildInputs = [
    gettext
    intltool
    python
  ];

  buildInputs = [
    glib
    glib-networking
    gobject-introspection
    libxml2
    sqlite
    vala
  ];

  postPatch = ''
    patchShebangs ./libsoup/
  '';

  # glib_networking is a runtime dependency, not a compile-time dependency
  configureFlags = [
    "--disable-debug"
    "--enable-glibtest"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-tls-check"
    "--disable-code-coverage"
    "--enable-more-warnings"
    "--with-gnome"
    #"--with-apache-httpd"
    #"--with-gssapi"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  passthru = {
    propagatedUserEnvPackages = [
      glib-networking
    ];
  };

  meta = with stdenv.lib; {
    description = "An HTTP library implementation in C";
    homepage = https://wiki.gnome.org/Projects/libsoup;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
