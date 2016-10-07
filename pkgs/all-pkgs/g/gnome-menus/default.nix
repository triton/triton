{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, lib

, glib
, gobject-introspection

, channel
}:

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-menus-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-menus/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  patches = [
    (fetchTritonPatch {
      rev = "e7b7c5f328fda18bc43aa8bbf73520441295850b";
      file = "gnome-menus/gnome-menus-3.13.3-multiple-desktop.patch";
      sha256 = "f22defd228de353d0c45ff69570c9dc7bdf20831a87f54aeb5c9e5ab3df0d232";
    })
    (fetchTritonPatch {
      rev = "e7b7c5f328fda18bc43aa8bbf73520441295850b";
      file = "gnome-menus/gnome-menus-3.13.3-multiple-desktop2.patch";
      sha256 = "2693e4f411e6b9a5f1f93bf3aaae70e88e23ae5139c00084e1154d489b1a48de";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-deprecation-flags"
    "--disable-debug"
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "INTROSPECTION_GIRDIR=$out/share/gir-1.0/"
      "INTROSPECTION_TYPELIBDIR=$out/lib/girepository-1.0"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-menus/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library for the Desktop Menu fd.o specification";
    homepage = https://git.gnome.org/browse/gnome-menus;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
