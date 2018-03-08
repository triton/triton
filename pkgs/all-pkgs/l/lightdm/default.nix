{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, itstool
, lib
, libxml2

, audit_lib
, glib
, libgcrypt
, libx11
, libxcb
, libxdmcp
, libxklavier
, pam
}:

let
  version = "1.25.2";
in
stdenv.mkDerivation rec {
  name = "lightdm-${version}";

  src = fetchurl {
    url = "https://github.com/CanonicalLtd/lightdm/releases/download/"
      + "${version}/${name}.tar.xz";
    sha256 = "8a6bc0b32dcf2e9183269c66c83ab2948e01ac7c560fe93b55dd4f61673d8eb0";
  };

  postPatch = ''
    grep -q '/usr/sbin/nologin' common/user-list.c
    sed -i common/user-list.c \
      -e 's,/usr/sbin/nologin,/usr/sbin/nologin /run/current-system/sw/bin/nologin,'
    grep -q '/usr/local/bin' src/session-child.c
    sed -i src/session-child.c \
      -e 's,/usr/local/bin:/usr/bin:/bin,/run/current-system/sw/bin,'
    grep -q '/bin/rm' src/shared-data-manager.c
    sed -i src/shared-data-manager.c \
      -e 's,/bin/rm,/run/current-system/sw/bin/rm,'
  '';

  nativeBuildInputs = [
    intltool
    itstool
    libxml2
  ];

  buildInputs = [
    audit_lib
    glib
    libgcrypt
    libx11
    libxcb
    libxdmcp
    libxklavier
    pam
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

  meta = with lib; {
    description = "Cross-desktop display manager";
    homepage = https://github.com/CanonicalLtd/lightdm;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
