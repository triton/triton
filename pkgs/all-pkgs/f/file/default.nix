{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.31";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmZukJ4ygPf8gB33rF2UxQTaBCJ1W9TEFojKgE2VjYXzz8";
    hashOutput = false;
    sha256 = "09c588dac9cff4baa054f51a36141793bcf64926edc909594111ceae60fce4ee";
  };

  buildInputs = [
    zlib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "BE04 995B A8F9 0ED0 C0C1  76C4 7111 2AB1 6CB3 3B3A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A program that shows the type of files";
    homepage = "http://darwinsys.com/file";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
