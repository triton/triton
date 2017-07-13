{ stdenv
, fetchurl
}:

let
  version = "2.7.2";
in
stdenv.mkDerivation rec {
  name = "mcpp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mcpp/mcpp/V.${version}/${name}.tar.gz";
    sha256 = "0r48rfghjm90pkdyr4khxg783g9v98rdx2n69xn8f6c5i0hl96rv";
  };

  configureFlags = [
    "--enable-mcpplib"
  ];

  meta = with stdenv.lib; {
    homepage = "http://mcpp.sourceforge.net/";
    description = "A portable c preprocessor";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
