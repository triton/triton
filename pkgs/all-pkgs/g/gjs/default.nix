{ stdenv
#, autoreconfHook
, fetchurl
, gettext
#, gnome-common
, lib

, atk
, cairo
, gdk-pixbuf
, glib
, gobject-introspection
, gtk
, libffi
, libxml2
, pango
, readline
, spidermonkey
, xorg

, channel
}:

let
  inherit (lib)
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gjs-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gjs/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    #autoreconfHook
    gettext
    #gnome-common
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    gtk
    libffi
    libxml2
    pango
    readline
    spidermonkey
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-cxx-warnings"
    "--disable-iso-cxx"
    "--disable-coverage"
    "--disable-installed-tests"
    "--disable-systemtap"
    "--disable-dtrace"
    "--enable-Bsymbolic"
    "--${boolWt (cairo != null)}-cairo"
    "--${boolWt (gtk != null)}-gtk"
    "--without-xvfb-tests"
    "--without-dbus-tests"
  ];

  postInstall = ''
    sed -i $out/lib/libgjs.la \
      -e 's|-lreadline|-L${readline}/lib -lreadline|g'
  '' + /* Remove empty directory tree (for installed tests) */ ''
    rm -frv $out/libexec
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gjs/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Javascript bindings for GNOME";
    homepage = https://wiki.gnome.org/Projects/Gjs;
    license = with licenses; [
      gpl2Plus
      lgpl2Plus
      mit
      mpl11
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
