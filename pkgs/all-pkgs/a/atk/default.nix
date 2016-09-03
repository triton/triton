{ stdenv
, gettext
, fetchurl
, perl

, glib
, gobject-introspection

, channel
}:

let
  inherit (stdenv.lib)
    enFlag;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "atk-${source.version}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/atk/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/atk/${channel}/${name}.sha256sum";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    perl
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  configureFlags = [
    "--enable-rebuilds"
    "--enable-glibtest"
    "--enable-nls"
    "--enable-rpath"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "GTK+ & GNOME Accessibility Toolkit";
    homepage = http://library.gnome.org/devel/atk/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
