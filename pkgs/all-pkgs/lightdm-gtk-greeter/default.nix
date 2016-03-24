{ stdenv
, fetchurl
, intltool
, makeWrapper

, glib
, gtk3
, hicolor_icon_theme
, lightdm
, xorg
}:

let
  ver_branch = "2.0";
  version = "2.0.1";
in
stdenv.mkDerivation rec {
  name = "lightdm-gtk-greeter-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm-gtk-greeter/${ver_branch}/${version}/+download/${name}.tar.gz";
    sha256 = "031iv7zrpv27zsvahvfyrm75zdrh7591db56q89k8cjiiy600r1j";
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    glib
    gtk3
    lightdm
    xorg.libX11
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
  ];

  preInstall = ''
    installFlagsArray+=(
      "localstatedir=$TMPDIR"
      "sysconfdir=$out/etc"
    )
  '';

  postInstall = ''
    substituteInPlace "$out/share/xgreeters/lightdm-gtk-greeter.desktop" \
      --replace "Exec=lightdm-gtk-greeter" "Exec=$out/sbin/lightdm-gtk-greeter"
    wrapProgram "$out/sbin/lightdm-gtk-greeter" \
      --prefix XDG_DATA_DIRS ":" "${hicolor_icon_theme}/share"
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
