{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "libaio-0.3.111";

  src = fetchurl {
    url = "https://releases.pagure.org/libaio/${name}.tar.gz";
    multihash = "QmSicVEFxtogFpjDnR2c1xSLJjkgPxSDcyNpbUUrP1A1Qq";
    sha256 = "62cf871ad8fd09eb3418f00aca7a7d449299b8e1de31c65f28bf6a2ef1fa502a";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with lib; {
    description = "Library for asynchronous I/O in Linux";
    homepage = http://lse.sourceforge.net/io/aio.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
