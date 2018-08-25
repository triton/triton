{ stdenv
, lib
, fetchurl

, ilmbase
, zlib
}:

let
  version = "2.3.0";
in
stdenv.mkDerivation rec {
  name = "openexr-${version}";

  src = fetchurl {
    url = "https://github.com/openexr/openexr/releases/download/v${version}/${name}.tar.gz";
    sha256 = "fd6cb3a87f8c1a233be17b94c74799e6241d50fc5efd4df75c7a4b9cf4e25ea6";
  };

  buildInputs = [
    ilmbase
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://www.openexr.com/;
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}
