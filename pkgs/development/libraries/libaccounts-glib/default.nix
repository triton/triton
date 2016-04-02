{ stdenv, fetchFromGitLab, autoconf, automake, glib
, gtk-doc, libtool, libxml2, libxslt, pkgconfig, sqlite }:

let version = "1.18"; in
stdenv.mkDerivation rec {
  name = "libaccounts-glib-${version}";

  src = fetchFromGitLab {
    sha256 = "f1fbfc89fe688e09d2a6b377d0a8ea61b293893b2bba3f9570b9551f6526e00d";
    rev = version;
    repo = "libaccounts-glib";
    owner = "accounts-sso";
  };

  buildInputs = [ glib libxml2 libxslt sqlite ];
  nativeBuildInputs = [ autoconf automake gtk-doc libtool pkgconfig ];

  postPatch = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  configurePhase = ''
    HAVE_GCOV_FALSE="#" ./configure $configureFlags --prefix=$out
  '';

  NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations"; # since glib-2.46
}
