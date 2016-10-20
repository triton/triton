{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, lib
, makeWrapper

, exo
, glib
, gobject-introspection
, gtk_3
, hicolor-icon-theme
, lightdm
, libxklavier
, xorg
}:

let
  inherit (lib)
    boolEn
    boolWt;

  channel = "2.0";
  version = "${channel}.2";
in
stdenv.mkDerivation rec {
  name = "lightdm-gtk-greeter-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm-gtk-greeter/${channel}/${version}/"
      + "+download/${name}.tar.gz";
    sha256 = "8ee6d93d1d6837b3590f64ac4d5bac5db888a8861dff1cb2ef10f7816ad36690";
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
    libxklavier
    xorg.libX11
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-maintainer-mode"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-libindicator"
    "--disable-libido"
    #"--enable-at-spi-command"
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
      -e "s,Exec=lightdm-gtk-greeter,Exec=$out/sbin/lightdm-gtk-greeter,"
    wrapProgram "$out/sbin/lightdm-gtk-greeter" \
      --prefix XDG_DATA_DIRS ":" "${hicolor-icon-theme}/share"
  '';

  meta = with stdenv.lib; {
    homepage = http://launchpad.net/lightdm-gtk-greeter;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
