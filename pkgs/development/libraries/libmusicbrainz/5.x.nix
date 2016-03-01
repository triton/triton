{ stdenv, fetchurl, cmake, perl, neon, libdiscid, libxml2 }:

stdenv.mkDerivation rec {
  name = "libmusicbrainz-5.0.1";

  buildInputs = [ cmake perl neon libdiscid libxml2 ];

  src = fetchurl {
    url = "https://github.com/downloads/metabrainz/libmusicbrainz/${name}.tar.gz";
    md5 = "a0406b94c341c2b52ec0fe98f57cadf3";
  };

  createCmakeBuildDir = false;

  meta = {
    homepage = http://musicbrainz.org/doc/libmusicbrainz;
    description = "MusicBrainz Client Library (5.x version)";
    longDescription = ''
      The libmusicbrainz (also known as mb_client or MusicBrainz Client
      Library) is a development library geared towards developers who wish to
      add MusicBrainz lookup capabilities to their applications.'';
    maintainers = [ stdenv.lib.maintainers.urkud ];
    platforms = stdenv.lib.platforms.all;
  };
}
