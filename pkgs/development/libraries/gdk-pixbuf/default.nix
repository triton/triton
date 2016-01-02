{ stdenv, fetchurl, pkgconfig, glib, libtiff, libjpeg, libpng, xorg
, jasper, libintlOrEmpty, gobjectIntrospection, doCheck ? false }:

let
  ver_maj = "2.32";
  ver_min = "3";
in
stdenv.mkDerivation rec {
  name = "gdk-pixbuf-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/gdk-pixbuf/${ver_maj}/${name}.tar.xz";
    sha256 = "2b6771f1ac72f687a8971e59810b8dc658e65e7d3086bd2e676e618fd541d031";
  };

  setupHook = ./setup-hook.sh;

  # !!! We might want to factor out the gdk-pixbuf-xlib subpackage.
  buildInputs = [ xorg.libX11 libintlOrEmpty ];

  nativeBuildInputs = [ pkgconfig gobjectIntrospection ];

  propagatedBuildInputs = [ glib libtiff libjpeg libpng jasper ];

  # on darwin, tests don't link
  preBuild = stdenv.lib.optionalString (stdenv.isDarwin && !doCheck) ''
    substituteInPlace Makefile --replace "docs tests" "docs"
  '';

  configureFlags = "--with-libjasper --with-x11"
    + stdenv.lib.optionalString (gobjectIntrospection != null) " --enable-introspection=yes"
    ;

  # The tests take an excessive amount of time (> 1.5 hours) and memory (> 6 GB).
  inherit (doCheck);

  postInstall = "rm -rf $out/share/gtk-doc";

  meta = {
    description = "A library for image loading and manipulation";
    homepage = http://library.gnome.org/devel/gdk-pixbuf/;
    maintainers = [ stdenv.lib.maintainers.eelco ];
    platforms = stdenv.lib.platforms.unix;
  };
}
