{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja

, qt5
}:

let
  version = "2017-09-06";
in
stdenv.mkDerivation rec {
  name = "adwaita-qt-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "MartinBriza";
    repo = "adwaita-qt";
    rev = "21835b9c8e3579f011d735643239423eaa2ef0c2";
    sha256 = "517389e561f18bdcb028ec6abd840cd99a8b69741842016a0e72463b83a3fc9a";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    qt5
  ];

  postPatch = /* Install styles in the correct prefix */ ''
    sed -i style/CMakeLists.txt \
      -e 's,''${QT_PLUGINS_DIR},''${CMAKE_INSTALL_PREFIX}/${qt5.plugindir},'
  '';

  cmakeFlags = [
    "-DUSE_QT4=OFF"
    "-DBUILD_EXAMPLE=OFF"
  ];

  meta = with lib; {
    description = "A Qt style to bend applications to look like GTK+";
    homepage = https://github.com/MartinBriza/adwaita-qt;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
