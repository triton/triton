{ stdenv
, fetchurl
, gettext
, ruby

, boost
, expat
, file
, flac
, libebml
, libiconv
, libmatroska
, libogg
, libvorbis
, qt5
, xdg_utils
, zlib
# pugixml (not packaged)
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "mkvtoolnix-${version}";
  version = "8.8.0";

  src = fetchurl {
    url = "http://www.bunkus.org/videotools/mkvtoolnix/sources/${name}.tar.xz";
    sha256 = "1751sf6brwwl1dq64155s4a12784q35dyqfy028qrwr1ilafhbci";
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
    qt5.qtbase
    xdg_utils
    zlib
  ] ++ optionals (!stdenv.cc.isGNU) [
    libiconv
  ];

  postPatch = ''
    patchShebangs ./rake.d/
    patchShebangs ./Rakefile
  '' +
  /* Force ruby encoding to UTF-8 or else when enabling qt5 the
     Rakefile mayfail with `invalid byte sequence in US-ASCII'
     due to UTF-8 characters. This workaround replaces an
     arbitrary comment in the drake file. */ ''
    sed -i ./drake \
      -e 's,#--,Encoding.default_external = Encoding::UTF_8,'
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
    "--disable-tools"
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
