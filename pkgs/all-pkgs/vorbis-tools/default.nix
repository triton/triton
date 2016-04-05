{ stdenv
, fetchurl
, fetchzip
, gettext

, curl
, flac
, libao
, libkate
, libogg
, libvorbis
, speex
}:

let
  debian-patches = stdenv.mkDerivation rec {
    name = "vorbis-tools-debian-patches-${version}";
    version = "1.4.0-8";
    src = fetchzip {
      url = "mirror://debian/pool/main/v/vorbis-tools/vorbis-tools_${version}.debian.tar.xz";
      sha256 = "8691688115d8ca3a3907aa5a194c746c7010dc283e68aca1d145e7be1f1a3e54";
    };
    buildPhase = "true";
    installPhase = ''
      mkdir -pv $out
      find . -type f -regextype posix-extended -regex ".*\.(diff|patch)" -exec cp -v {} $out \;
    '';
  };
in

stdenv.mkDerivation rec {
  name = "vorbis-tools-1.4.0";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/vorbis/${name}.tar.gz";
    sha256Url = http://downloads.xiph.org/releases/vorbis/SHA256SUMS;
    sha256 = "a389395baa43f8e5a796c99daf62397e435a7e73531c9f44d9084055a05d22bc";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    curl
    flac
    libao
    libkate
    libogg
    libvorbis
    speex
  ];

  postPatch = ''
    find "${debian-patches}" -type f -regextype posix-extended -regex ".*\.(diff|patch)" |
    while read patch ; do
      patch --verbose -p1 < "$patch"
    done
  '';

  meta = with stdenv.lib; {
    description = "Extra tools for Ogg-Vorbis audio codec";
    homepage = http://xiph.org/vorbis/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

