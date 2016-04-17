{ stdenv
, fetchurl
, cmake
, docbook_xml_dtd_45
, docbook_xsl
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
, qt4
, readline
, taglib
, zlib
}:

let
  inherit (stdenv.lib)
    cmFlag;
in

stdenv.mkDerivation rec {
  name = "kid3-${version}";
  version = "3.3.2";

  src = fetchurl {
    url = "mirror://sourceforge/kid3/kid3/${version}/${name}.tar.gz";
    sha256 = "d54c164e38ee8ff2c35473a7158e2748cbb6a9472822a96decf6e34a15458957";
  };

  nativeBuildInputs = [
    cmake
    docbook_xml_dtd_45
    docbook_xsl
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
    qt4
    readline
    taglib
    zlib
  ];

  preConfigure = ''
    export DOCBOOKDIR="${docbook_xsl}/xml/xsl/docbook/"
  '';

  cmakeFlags = [
    #QT_QMAKE_EXECUTABLE:FILEPATH=NOTFOUND
    #Qt5Core_DIR:PATH=Qt5Core_DIR-NOTFOUND
    "-DWITH_APPS=QT;CLI" #KDE
    (cmFlag "WITH_CHROMAPRINT" (chromaprint != null))
    #WITH_CHROMAPRINT_FFMPEG:BOOL=OFF
    (cmFlag "WITH_DBUS" (dbus != null))
    (cmFlag "WITH_FFMPEG" (ffmpeg != null))
    (cmFlag "WITH_FLAC" (flac != null))
    (cmFlag "WITH_GSTREAMER" (gstreamer != null))
    (cmFlag "WITH_ID3LIB" (id3lib != null))
    (cmFlag "WITH_MP4V2" (mp4v2 != null))
    (cmFlag "WITH_PHONON" false)
    #WITH_QAUDIODECODER:BOOL=OFF
    #WITH_QML:BOOL=ON
    "-DWITH_QT4=ON"
    "-DWITH_QT5=OFF"
    (cmFlag "WITH_READLINE" (readline != null))
    (cmFlag "WITH_TAGLIB" (taglib != null))
    #WITH_UBUNTUCOMPONENTS:BOOL=OFF
    (cmFlag "WITH_VORBIS" (libvorbis != null))
  ];

  meta = with stdenv.lib; {
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
