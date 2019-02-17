{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja

, qt5
}:

let
  version = "2018-03-29";
in
stdenv.mkDerivation rec {
  name = "adwaita-qt-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "FedoraQt";
    repo = "adwaita-qt";
    rev = "30decc8a0be929bb0344e192140456552e32dd41";
    sha256 = "62d1defa1502f5e9d16c687bb6cb6ddacaa03e1a970fe218075838f985a36590";
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
