{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libopus-${version}";
  version = "1.1.2";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/opus/opus-${version}.tar.gz";
    sha256 = "1z87x5c5x951lhnm70iqr2gqn15wns5cqsw8nnkvl48jwdw00a8f";
  };

  configureFlags = [
    "--enable-custom-modes"
  ];

  meta = with stdenv.lib; {
    description = "Open, royalty-free, highly versatile audio codec";
    license = stdenv.lib.licenses.bsd3;
    homepage = http://www.opus-codec.org/;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}
