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
  version = "1.18.1";
in

stdenv.mkDerivation rec {
  name = "lightdm-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm/${ver_branch}/${version}/+download/${name}.tar.xz";
    sha256 = "85488565e42089ec025a2f330cff97fa615b02777dbab86a916b209a2cfc89fa";
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
