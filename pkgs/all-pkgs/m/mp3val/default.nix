{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mp3val-0.1.8";

  src = fetchurl {
    url = "mirror://sourceforge/mp3val/${name}-src.tar.gz";
    multihash = "QmcHZ2vRHQbRB5ExTnUMCPFdUcPFeHUJBTZR2Mfw7riGJh";
    sha256 = "17y3646ghr38r620vkrxin3dksxqig5yb3nn4cfv6arm7kz6x8cm";
  };

  makefile = "Makefile.linux";

  installPhase = ''
    install -D -m755 -v 'mp3val' "$out/bin/mp3val"
  '';

  fortifySource = false;

  meta = with stdenv.lib; {
    description = "A tool for validating and repairing MPEG audio streams";
    homepage = http://mp3val.sourceforge.net/index.shtml;
    license = stdenv.lib.licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
