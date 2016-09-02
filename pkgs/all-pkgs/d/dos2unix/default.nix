{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "dos2unix-7.3.4";
  
  src = fetchurl {
    url = "http://waterlan.home.xs4all.nl/dos2unix/${name}.tar.gz";
    hashOutput = false;
    sha256 = "8ccda7bbc5a2f903dafd95900abb5bf5e77a769b572ef25150fde4056c5f30c5";
  };

  nativeBuildInputs = [
    gettext
  ];

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "F8F1 BEA4 9049 6A09 CCA3  28CC 38C1 F572 B127 25BE";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tools to transform text files from dos to unix formats";
    homepage = http://waterlan.home.xs4all.nl/dos2unix.html;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
