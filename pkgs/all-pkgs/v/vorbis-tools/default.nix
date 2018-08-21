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
  debian-patches-version = "1.4.0-10";

  debian-patches = stdenv.mkDerivation rec {
    name = "vorbis-tools-debian-patches-${debian-patches-version}";

    src = fetchzip {
      version = 6;
      url = "mirror://debian/pool/main/v/vorbis-tools/vorbis-tools_${debian-patches-version}.debian.tar.xz";
      sha256 = "6708f89359ea4c255030fdcdf9ddf9c7c5e6549eb46acf41f6791c8d22ceab7c";
    };

    installPhase = ''
      mkdir -pv $out
      find . -type f -regextype posix-extended -regex ".*\.(diff|patch)" -exec cp -v {} $out \;
    '';
  };
in

stdenv.mkDerivation rec {
  name = "vorbis-tools-1.4.0";

  src = fetchurl {
    url = "mirror://xiph/vorbis/${name}.tar.gz";
    fullOpts = {
      sha256Url = mirror://xiph/vorbis/SHA256SUMS;
    };
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

