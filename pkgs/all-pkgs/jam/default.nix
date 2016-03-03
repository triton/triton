{ stdenv
, fetchurl
, bison
}:

stdenv.mkDerivation rec {
  name = "ftjam-${version}";
  version = "2.5.2";

  src = fetchurl {
    url = "mirror://sourceforge/freetype/ftjam/${version}/${name}.tar.bz2";
    sha256 = "18v6dn52n0sfbx1r9wcssrwwwssbpvxbzzp933ljv4cj198775z8";
  };

  nativeBuildInputs = [
    bison
  ];

  meta = with stdenv.lib; {
    homepage = http://public.perforce.com/wiki/Jam;
    description = "Just Another Make";
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
