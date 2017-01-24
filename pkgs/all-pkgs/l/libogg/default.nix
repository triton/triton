{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libogg-1.3.2";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/ogg/${name}.tar.xz";
    multihash = "QmPMKrTQv2CB3bkrCb38Qky3RS1jHB4wDxyGcEwn67o29A";
    sha256 = "16z74q422jmprhyvy7c9x909li8cqzmvzyr8cgbm52xcsp6pqs1z";
  };

  meta = with stdenv.lib; {
    homepage = http://xiph.org/ogg/;
    license = licenses.bsd3;
    maintainers = [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
