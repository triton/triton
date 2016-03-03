{ stdenv
, fetchurl
, gnum4

, gmp
}:

stdenv.mkDerivation rec {
  name = "nettle-3.2";

  src = fetchurl {
    url = "mirror://gnu/nettle/${name}.tar.gz";
    sha256 = "15wxhk52yc62rx0pddmry66hqm6z5brrrkx4npd3wh9nybg86hpa";
  };

  nativeBuildInputs = [
    gnum4
  ];

  buildInputs = [
    gmp
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Cryptographic library";
    homepage = http://www.lysator.liu.se/~nisse/nettle/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
