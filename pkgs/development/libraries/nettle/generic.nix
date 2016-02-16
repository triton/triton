{ stdenv, gmp, gnum4

# Version specific args
, version, src
, ...}:

stdenv.mkDerivation rec {
  name = "nettle-${version}";

  inherit src;

  buildInputs = [ gnum4 ];
  propagatedBuildInputs = [ gmp ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Cryptographic library";
     license = licenses.gpl2Plus;
     homepage = http://www.lysator.liu.se/~nisse/nettle/;
     maintainers = with maintainers; [ wkennington ];
     platforms = platforms.all;
  };
}
