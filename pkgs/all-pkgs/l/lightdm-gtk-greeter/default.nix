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
  version = "${channel}.4";
in
stdenv.mkDerivation rec {
  name = "lightdm-gtk-greeter-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm-gtk-greeter/${channel}/${version}/"
      + "+download/${name}.tar.gz";
    multihash = "QmbFMke1KXqnYyBBWxB74N4c5SBnJMVAiMNRcGu6x1AwQH";
    sha256 = "613b5966dad749e3e316352a9fa7d6380392be4c875b10a6384dd04105f66beb";
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
    wrapProgram "$out/sbin/lightdm-gtk-greeter" \
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
