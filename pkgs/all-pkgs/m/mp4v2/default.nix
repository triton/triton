{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mp4v2-2.0.0";

  src = fetchurl {
    url = "https://mp4v2.googlecode.com/files/${name}.tar.bz2";
    multihash = "QmUqS6HpKpUxXm7Pun24MAewxdLT6RGjt4siDvzJTf7nbV";
    sha256 = "0319b9a60b667cf10ee0ec7505eb7bdc0a2e21ca7a93db96ec5bd758e3428338";
  };

  meta = with stdenv.lib; {
    description = "Functions for accessing ISO-IEC:14496-1:2001 MPEG-4 standard";
    homepage = http://code.google.com/p/mp4v2;
    license = licenses.mpl11;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
