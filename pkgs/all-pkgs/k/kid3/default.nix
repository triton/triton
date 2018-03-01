{ stdenv
, fetchurl
, cmake
, docbook_xml_dtd_45
, docbook-xsl
, lib
, libxslt
, ninja
, perl

#, automoc4
, chromaprint
, dbus
, ffmpeg
, flac
, gstreamer
, id3lib
, libogg
, libvorbis
, mp4v2
#, phonon
, python
, qt5
, readline
, taglib
, zlib
}:

let
  inherit (lib)
    boolOn;

  version = "3.5.1";
in
stdenv.mkDerivation rec {
  name = "kid3-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/kid3/kid3/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "88c20826deb13f81bcdfa7033a4b9ff9ca8957112b2fa2ccc0a9a1076df73926";
  };

  nativeBuildInputs = [
    cmake
    docbook_xml_dtd_45
    docbook-xsl
    libxslt
    ninja
    perl
  ];

  buildInputs = [
    chromaprint
    ffmpeg
    flac
    id3lib
    mp4v2
    libogg
    libvorbis
    #phonon
    python
    qt5
    readline
    taglib
    zlib
  ];

  preConfigure = ''
    export DOCBOOKDIR="${docbook-xsl}/xml/xsl/docbook/"
  '';

  cmakeFlags = [
    #QT_QMAKE_EXECUTABLE:FILEPATH=NOTFOUND
    #Qt5Core_DIR:PATH=Qt5Core_DIR-NOTFOUND
    "-DWITH_APPS=QT;CLI" #KDE
    "-DWITH_CHROMAPRINT=${boolOn (chromaprint != null)}"
    #WITH_CHROMAPRINT_FFMPEG:BOOL=OFF
    "-DWITH_DBUS=${boolOn (dbus != null)}"
    "-DWITH_FFMPEG=${boolOn (ffmpeg != null)}"
    "-DWITH_FLAC=${boolOn (flac != null)}"
    "-DWITH_GSTREAMER=${boolOn (gstreamer != null)}"
    "-DWITH_ID3LIB=${boolOn (id3lib != null)}"
    "-DWITH_MP4V2=${boolOn (mp4v2 != null)}"
    "-DWITH_PHONON=OFF"
    #WITH_QAUDIODECODER:BOOL=OFF
    #WITH_QML:BOOL=ON
    "-DWITH_QT4=OFF"
    "-DWITH_QT5=ON"
    "-DWITH_READLINE=${boolOn (readline != null)}"
    "-DWITH_TAGLIB=${boolOn (taglib != null)}"
    #WITH_UBUNTUCOMPONENTS:BOOL=OFF
    "-DWITH_VORBIS=${boolOn (libvorbis != null)}"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "7D09 794C 2812 F621 94B0  81C1 4CAD 3442 6E35 4DD2";
    };
  };

  meta = with lib; {
    description = "A simple and powerful audio tag editor";
    homepage = http://kid3.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
