{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, makeWrapper

, glib
, gtk3
, hicolor-icon-theme
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

  # Disable -Werror as there are issues with 2.0.1 on gcc 6.1.0
  prePatch = ''
    sed -i 's,-Werror[^ "]*,,g' configure
  '';

  patches = [
    # Remove after 2.0.1
    (fetchTritonPatch {
      rev = "77e91ff8ea4b2a4d01c6618c7d98649e0a2db66b";
      file = "lightdm-gtk-greeter/lightdm-gtk-greeter-2.0.1-r339-fix-deprecated-gdk-cursor.patch";
      sha256 = "2de9eb1f182260cc36cde1edb4deae215f1396c263bc365f0869e3447774b84d";
    })
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
      --prefix XDG_DATA_DIRS ":" "${hicolor-icon-theme}/share"
  '';

  parallelBuild = false;

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
