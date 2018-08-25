{ stdenv
, fetchurl
, gettext
#, gtk-doc
, lib

, glib
, gobject-introspection
, iso-codes
, libx11
, libxi
, libxkbfile
, libxml2
, vala
, xkbcomp
, xkeyboard-config
}:

let
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "libxklavier-5.4";

  src = fetchurl rec {
    url = "http://pkgs.fedoraproject.org/repo/pkgs/libxklavier/${name}.tar.bz2/${fullOpts.md5Confirm}/${name}.tar.bz2";
    multihash = "QmNdE3S2pGqMgj7vkNg8XwMxKiws8zfupnm3FnpXGnEQc8";
    sha256 = "17a34194df5cbcd3b7bfd0f561d95d1f723aa1c87fca56bc2c209514460a9320";
  };

  nativeBuildInputs = [
    gettext
    #gtk-doc
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    iso-codes
    libx11
    libxi
    libxkbfile
    libxml2
    xkbcomp
    xkeyboard-config
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-rpath"
    "--enable-nls"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (libxkbfile != null)}-xkb-support"
    "--enable-xmodmap-support"
  ];

  meta = with lib; {
    description = "Library providing high-level API for X Keyboard Extension known as XKB";
    homepage = http://freedesktop.org/wiki/Software/LibXklavier;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
