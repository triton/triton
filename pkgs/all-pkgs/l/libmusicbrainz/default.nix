{ stdenv
, cmake
, fetchurl
, ninja
, perl

, libdiscid
, libxml2
, neon
}:

stdenv.mkDerivation rec {
  name = "libmusicbrainz-${version}";
  version = "5.1.0";

  src = fetchurl {
    url = "https://github.com/metabrainz/libmusicbrainz/releases/download/"
      + "release-${version}/${name}.tar.gz";
    sha256 = "6749259e89bbb273f3f5ad7acdffb7c47a2cf8fcaeab4c4695484cef5f4c6b46";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libdiscid
    libxml2
    neon
  ];

  createBuildRoot = false;

  meta = with stdenv.lib; {
    description = "MusicBrainz Client Library";
    homepage = http://musicbrainz.org/doc/libmusicbrainz;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
