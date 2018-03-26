{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, lib
, makeWrapper

, at-spi2-core
, exo
, gdk-pixbuf
, glib
, gobject-introspection
, gtk_3
, hicolor-icon-theme
, lightdm
, libx11
, libxklavier
, shared-mime-info
}:

let
  inherit (lib)
    boolEn
    boolWt;

  channel = "2.0";
  version = "${channel}.5";
in
stdenv.mkDerivation rec {
  name = "lightdm-gtk-greeter-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm-gtk-greeter/${channel}/${version}/"
      + "+download/${name}.tar.gz";
    multihash = "QmefqZ9Mru3HxDbbgcaQNCfuu1gte93e5cF3yVzncMDw85";
    sha256 = "5dc608d58ff9d15117c9d99b55e5f038d39e2f1691f03ce1dc1c8881560387df";
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    exo
    glib
    gobject-introspection
    gtk_3
    lightdm
    libx11
    libxklavier
  ];

  preConfigure = ''
    configureFlagsArray+=(
      '--enable-at-spi-command=${at-spi2-core}/libexec/at-spi-bus-launcher --launch-immediately'
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-maintainer-mode"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-libindicator"
    "--disable-libido"
    "--disable-indicator-services-command"
    #"--enable-kill-on-sigterm"
    "--enable-nls"
    "--${boolWt (libxklavier != null)}-libxklavier"
  ];

  preInstall = ''
    installFlagsArray+=(
      "localstatedir=$TMPDIR"
      "sysconfdir=$out/etc"
    )
  '';

  postInstall = ''
    sed -i "$out/share/xgreeters/lightdm-gtk-greeter.desktop" \
      -e "s,Exec=lightdm-gtk-greeter,Exec=$out/bin/lightdm-gtk-greeter,"
    wrapProgram "$out/bin/lightdm-gtk-greeter" \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --prefix XDG_DATA_DIRS ':' "${hicolor-icon-theme}/share" \
      --prefix XDG_DATA_DIRS ':' "${shared-mime-info}/share"
  '';

  meta = with lib; {
    description = "LightDM GTK+ Greeter";
    homepage = http://launchpad.net/lightdm-gtk-greeter;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
