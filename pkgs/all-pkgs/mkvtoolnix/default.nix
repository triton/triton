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

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

assert qt5 != null -> qt5.qtbase != null;

stdenv.mkDerivation rec {
  name = "mkvtoolnix-${version}";
  version = "9.0.1";

  src = fetchurl {
    url = "https://mkvtoolnix.download/sources/${name}.tar.xz";
    sha256 = "292504633d714c42f73f08474137e462827f6d8d570292005bbaebb8fee8e52e";
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
