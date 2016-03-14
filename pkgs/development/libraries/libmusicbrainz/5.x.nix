{ stdenv, fetchurl, cmake, perl, neon, libdiscid, libxml2 }:

stdenv.mkDerivation rec {
  name = "libmusicbrainz-5.0.1";

  buildInputs = [ cmake perl neon libdiscid libxml2 ];

  src = fetchurl {
    url = "https://github.com/downloads/metabrainz/libmusicbrainz/${name}.tar.gz";
    sha256 = "1mc2vfsnyky49s25yc64zijjmk4a8qgknqw21l5n58sra0f5x9qw";
  };

  createCmakeBuildDir = false;

  meta = {
    homepage = http://musicbrainz.org/doc/libmusicbrainz;
    description = "MusicBrainz Client Library (5.x version)";
    maintainers = [ ];
    platforms = stdenv.lib.platforms.all;
  };
}
