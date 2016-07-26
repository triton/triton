{ stdenv
, fetchurl
, intltool
, itstool
, libxml2

, audit_lib
, glib
, libgcrypt
, libxklavier
, pam
, xorg
}:

let
  ver_branch = "1.18";
  version = "1.18.2";
in

stdenv.mkDerivation rec {
  name = "lightdm-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm/${ver_branch}/${version}/+download/${name}.tar.xz";
    sha256 = "fd97dfc8af9c6e14c9919d1c13a4a8a68a046621ad5f404ca4e3c84895ab0e5c";
  };

  patches = [
    ./fix-paths.patch
  ];

  nativeBuildInputs = [
    intltool
    itstool
    libxml2
  ];

  buildInputs = [
    audit_lib
    glib
    libgcrypt
    libxklavier
    pam
    xorg.libX11
    xorg.libXdmcp
    xorg.libxcb
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-tests"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIr"
    )
  '';

  meta = with stdenv.lib; {
    homepage = https://launchpad.net/lightdm;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
