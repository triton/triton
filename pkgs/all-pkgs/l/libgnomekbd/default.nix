{ stdenv
, fetchurl
, file
, intltool
, lib
, makeWrapper

, atk
, gdk-pixbuf
, glib
, gobject-introspection
, gtk_3
, libx11
, libxklavier
, pango

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgnomekbd-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgnomekbd/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    glib
    gobject-introspection
    gtk_3
    libx11
    libxklavier
    pango
  ];

  configureFlags = [
    "--disable-schemas-compile"
    "--enable-nls"
    "--enable-rpath"
    "--disable-tests"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolWt (libx11 != null)}-x"
  ];

  preFixup = ''
    wrapProgram $out/bin/gkbd-keyboard-display \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgnomekbd/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Gnome keyboard configuration library";
    homepage = https://www.gnome.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
