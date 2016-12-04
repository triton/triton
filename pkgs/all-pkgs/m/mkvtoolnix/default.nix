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
    boolEn
    boolString
    boolWt
    optionals;
in
stdenv.mkDerivation rec {
  name = "mkvtoolnix-9.6.0";

  src = fetchurl {
    url = "https://mkvtoolnix.download/sources/${name}.tar.xz";
    multihash = "QmWN4NXBxNPJXjt6uHixqrcPqBfBLymMRUjuejbqCtAwCQ";
    sha256 = "ebab8dcc59533d248b127d375286eb47880a222ef68ff7a10e1c87d49dbd86bb";
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
    qt5
    xdg-utils
    zlib
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
    "--${boolEn (qt5 != null)}-qt"
    "--disable-static-qt"
    "--enable-magic"
    "--${boolWt (flac != null)}-flac"
    "--without-curl"
    "--${boolWt (boost != null)}-boost"
    "--${boolWt (boost != null)}-boost-libdir${
      boolString (boost != null) "=${boost.lib}/lib" ""}"
    "--with-gettext"
    "--without-tools"
  ];

  buildPhase = ''
    ./drake -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    ./drake -j $NIX_BUILD_CORES install
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "D919 9745 B054 5F2E 8197  062B 0F92 290A 445B 9007";
    };
  };

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
