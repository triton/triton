{ stdenv
, cmake
, extra-cmake-modules
, fetchurl
, ninja
, pythonPackages

, pam
, qt5
, systemd_full
, xorg
}:

stdenv.mkDerivation {
  name = "sddm-0.14.0";

  src = fetchurl {
    url = "https://github.com/sddm/sddm/releases/download/v0.14.0/sddm-0.14.0.tar.xz";
    sha256 = "7e348258618b20f777767a98f9e377b48824b5cb5aad3a3f10f8482c1eb27778";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    pythonPackages.docutils
  ];

  buildInputs = [
    pam
    qt5
    systemd_full
    xorg.libxcb
  ];

  preConfigure = ''
    touch "$TMPDIR/login.defs"
    cmakeFlagsArray+=(
      "-DQT_IMPORTS_DIR=$out/lib/qt5/qml"
      "-DSYSTEMD_SYSTEM_UNIT_DIR=$out/lib/systemd/system"
      "-DCMAKE_INSTALL_SYSCONFDIR=$out/etc"
      "-DCMAKE_INSTALL_LOCALSTATEDIR=$TMPDIR"
      "-DLOGIN_DEFS_PATH=$TMPDIR/login.defs"
    )
  '';

  cmakeFlags = [
    "-DBUILD_MAN_PAGES=ON"
    "-DUID_MIN=1000"
    "-DUID_MAX=2147483647"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
