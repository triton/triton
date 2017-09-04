{ stdenv
, fetchurl
, lib

, libbsd
}:

let
  version = "2.2.4";
in
stdenv.mkDerivation rec {
  name = "expat-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/expat/expat/${version}/${name}.tar.bz2";
    sha256 = "03ad85db965f8ab2d27328abcf0bc5571af6ec0a414874b2066ee3fdd372019e";
  };

  configureFlags = [
    "--with-libbsd"
  ];

  buildInputs = [
    libbsd
  ];

  meta = with lib; {
    description = "A stream-oriented XML parser library written in C";
    homepage = http://www.libexpat.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
