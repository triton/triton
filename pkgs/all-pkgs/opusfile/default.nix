{ stdenv
, fetchurl

, libogg
, openssl
, opus
}:

stdenv.mkDerivation rec {
  name = "opusfile-0.8";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/opus/${name}.tar.gz";
    sha256Url = "http://downloads.xiph.org/releases/opus/SHA256SUMS.txt";
    sha256 = "2c231ed3cfaa1b3173f52d740e5bbd77d51b9dfecb87014b404917fba4b855a4";
  };

  buildInputs = [
    libogg
    openssl
    opus
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-assertions"
    "--enable-http"
    "--disable-fixed-point"
    "--enable-float"
    "--enable-examples"
    "--disable-doc"
  ];

  meta = with stdenv.lib; {
    description = "High-level API for decoding and seeking in .opus files";
    homepage = http://www.opus-codec.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
