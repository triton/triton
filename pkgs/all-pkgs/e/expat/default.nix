{ stdenv
, fetchurl
, lib
}:

let
  version = "2.2.3";
in
stdenv.mkDerivation rec {
  name = "expat-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/expat/expat/${version}/${name}.tar.bz2";
    sha256 = "b31890fb02f85c002a67491923f89bda5028a880fd6c374f707193ad81aace5f";
  };

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
