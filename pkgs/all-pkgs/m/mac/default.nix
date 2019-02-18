{ stdenv
, fetchurl
, yasm
}:

stdenv.mkDerivation rec {
  name = "mac-3.99.4.5.7";

  src = fetchurl {
    url = "http://www.etree.org/shnutils/shntool/support/formats/ape/unix/"
        + "3.99-u4-b5-s7/mac-3.99-u4-b5-s7.tar.gz";
    sha256 = "9a735af2c56f05ee06b6e2ff719e902271299adf9e25cd3c9e4b28e8df3e30c5";
  };

  nativeBuildInputs = [
    yasm
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-assembly"
  ];

  CXXFLAGS = "-DSHNTOOL";

  meta = with stdenv.lib; {
    description = "Monkey's Audio Codecs";
    homepage = http://etree.org/shnutils/shntool/;
    license = licenses.free; #mac
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
