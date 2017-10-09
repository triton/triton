{ stdenv
, cmake
, extra-cmake-modules
, fetchurl
, ninja
, pythonPackages

, pam
, qt5
, systemd_lib
, xorg
}:

let
  version = "0.16.0";
in
stdenv.mkDerivation {
  name = "sddm-${version}";

  src = fetchurl {
    url = "https://github.com/sddm/sddm/releases/download/v${version}/sddm-${version}.tar.xz";
    hashOutput = false;  # https://github.com/sddm/sddm/releases
    sha256 = "e9138a23e7f0846f7dcb925964d301f1a597fae2047b373d7dbe4cd5340f8e3b";
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
    systemd_lib
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
