{ stdenv
, fetchurl
, gettext
, ruby

, boost
, expat
, file
, flac
, libebml
, libmatroska
, libogg
, libvorbis
, pugixml
, qt5
, xdg-utils
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
};

assert qt5 != null -> qt5.qtbase != null;

stdenv.mkDerivation rec {
  name = "mkvtoolnix-${version}";
  version = "8.9.0";

  src = fetchurl {
    url = "http://www.bunkus.org/videotools/mkvtoolnix/sources/${name}.tar.xz";
    sha256 = "1m50m8lkfpk0663zhhx9alvprf2y6b4lj9wj29xn3a1rjf2b421j";
  };

  nativeBuildInputs = [
    gettext
    ruby
  ];

  buildInputs = [
    boost
    expat
    file
    flac
    libebml
    libmatroska
    libogg
    libvorbis
    pugixml
    xdg-utils
    zlib
  ] ++ optionals (qt5 != null) [
    qt5.qtbase
  ];

  postPatch = ''
    patchShebangs ./rake.d/
    patchShebangs ./Rakefile
  '';

  configureFlags = [
    "--disable-debug"
    "--disable-profiling"
    "--enable-optimization"
    "--disable-precompiled-headers"
    (enFlag "qt" (qt5 != null) null)
    "--disable-static-qt"
    "--enable-magic"
    (wtFlag "flac" (flac != null) null)
    "--without-curl"
    (wtFlag "boost" (boost != null) null)
    (wtFlag "boost-libdir" (boost != null) "${boost.lib}/lib")
    "--with-gettext"
    "--without-tools"
  ];

  buildPhase = ''
    ./drake -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    ./drake install -j $NIX_BUILD_CORES
  '';

  meta = with stdenv.lib; {
    description = "Cross-platform tools for Matroska";
    homepage = http://www.bunkus.org/videotools/mkvtoolnix/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
