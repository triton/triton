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
  name = "mkvtoolnix-9.4.0";

  src = fetchurl {
    url = "https://mkvtoolnix.download/sources/${name}.tar.xz";
    multihash = "Qmd5dq1S9xeXHPmnaH1e86yCWDJ84p92eF7H5RGnd3LXrm";
    sha256 = "af633768ac3ca193070c76c93bbf496b41e451d1652e1d3d6fd4c20361e56265";
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
