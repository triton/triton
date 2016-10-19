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
  ver_branch = "1.20";
  version = "1.20.0";
in

stdenv.mkDerivation rec {
  name = "lightdm-${version}";

  src = fetchurl {
    url = "https://launchpad.net/lightdm/${ver_branch}/${version}/+download/${name}.tar.xz";
    sha256 = "f03b7804a4902d189849a060292e4987d1e4f8272a1edb3e681e6f3cdfaa5ba4";
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
