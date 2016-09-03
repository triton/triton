{ stdenv
, autoreconfHook
, fetchFromGitLab
, gtk-doc
, libtool
, libxslt

, glib
, gobject-introspection
, libxml2
, sqlite
}:

let
  inherit (stdenv.lib)
    boolEn;

  version = "1.22";
in
stdenv.mkDerivation rec {
  name = "libaccounts-glib-${version}";

  src = fetchFromGitLab {
    version = 2;
    owner = "accounts-sso";
    repo = "libaccounts-glib";
    rev = "VERSION_${version}";
    sha256 = "00502aaf6547efdedbd279408dcc85e83dccee8854f4314a04f7fe079a97d60c";
  };

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    libtool
    libxslt
  ];

  buildInputs = [
    glib
    gobject-introspection
    libxml2
    sqlite
  ];

  postPatch = ''
    gtkdocize --copy --flavour no-tmpl
  '';

  configureFlags = [
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-tests"
    "--disable-gcov"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-cast-checks"
    "--enable-asserts"
    "--enable-checks"
    "--disable-debug"
    "--enable-wal"
    "--enable-python"
    "--disable-man"
  ];

  makeFlags = [
    "INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0/"
  ];

  meta = with stdenv.lib; {
    description = "GLib-based client library for the accounts database";
    homepage = https://gitlab.com/accounts-sso/libaccounts-glib;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
    codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
