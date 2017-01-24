{ stdenv
, fetchurl
, gettext
, intltool
, lib

, glib

, channel
}:

let
  inherit (stdenv.lib)
    optionalAttrs;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "libxfce4util-${source.version}";

  src = fetchurl ({
    url = "http://archive.xfce.org/src/xfce/libxfce4util/${channel}/"
      + "${name}.tar.bz2";
    hashOutput = false;
    inherit (source) sha256;
  } // optionalAttrs (source ? multihash) {
    inherit (source) multihash;
  });

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-debug"
    #"--disable-linker-opts"
    #"--disable-visibility"
    "--without-broken-putenv"
  ];

  meta = with lib; {
    description = "A basic utility library for the Xfce desktop environment";
    homepage = http://www.xfce.org/projects/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
