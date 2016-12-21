{ stdenv
, fetchurl
, shared ? true
, static ? true
}:

assert static || shared;

let
  version = "2016-12-04";
in
stdenv.mkDerivation rec {
  name = "zlib-${version}";

  src = fetchurl {
    url = "https://github.com/wkennington/zlib/releases/download/${version}/${name}.tar.xz";
    multihash = "QmS2XU2FfGp6oA8v9hYCVfDRNrXLub37cCtLKj87QypgXh";
    sha256 = "12657d09bb77e092f189ea1201adaacb35aef1bcf788393e46956019e4e0c8e7";
  };

  configureFlags = [
    (if static then "--static" else "")
    (if shared then "--shared" else "")
  ];

  meta = with stdenv.lib; {
    description = "Lossless data-compression library";
    homepage = http://www.zlib.net/;
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
