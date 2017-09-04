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

let
  version = "0.15.0";
in
stdenv.mkDerivation {
  name = "sddm-${version}";

  src = fetchurl {
    url = "https://github.com/sddm/sddm/releases/download/v${version}/sddm-${version}.tar.gz";
    hashOutput = false;  # https://github.com/sddm/sddm/releases
    sha256 = "a4211e5b66f674415e07bc1cc39c16f60ae6025418bcbaba1118cd51e57c3174";
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
