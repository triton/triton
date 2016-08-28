{ stdenv
, cmake
, fetchurl
, ninja

, qt5
, zlib
}:

stdenv.mkDerivation rec {
  name = "quazip-0.7.2";

  src = fetchurl {
    url = "mirror://sourceforge/quazip/${name}.tar.gz";
    multihash = "QmcsoRmDrzPyJYhRuDQo4rf9sEzTcJDubVPJ5qEyKq7Uw3";
    sha256 = "91d827fbcafd099ae814cc18a8dd3bb709da6b8a27c918ee1c6c03b3f29440f4";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    qt5
    zlib
  ];

  postPatch = /* Don't install CMake module in CMake's PREFIX */ ''
    sed -i CMakeLists.txt \
      -e 's/CMAKE_ROOT/CMAKE_SOURCE_DIR/'
  '';

  cmakeFlags = [
    "-DBUILD_WITH_QT4=OFF"
  ];

  postInstall = /* Create symlink for compatibility */ ''
    ln -sv $out/lib/libquazip5.so \
      $out/lib/libquazip.so
  '';

  meta = with stdenv.lib; {
    description = "Provides access to ZIP archives from Qt programs";
    homepage = http://quazip.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
