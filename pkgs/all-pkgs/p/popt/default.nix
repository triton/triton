{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "popt-1.16";

  src = fetchurl {
    url = "http://rpm5.org/files/popt/${name}.tar.gz";
    multihash = "QmNisvSKk69tVbfBLauPyHbYvY6kfzUnqhJ1sAsS3iLSw8";
    sha256 = "1j2c61nn2n351nhj4d25mnf3vpiddcykq005w2h6kw79dwlysa77";
  };

  meta = with stdenv.lib; {
    description = "command line option parsing library";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
