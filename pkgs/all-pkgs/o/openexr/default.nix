{ stdenv
, lib
, fetchurl

, ilmbase
, zlib
}:

let
  version = "2.2.1";
in
stdenv.mkDerivation rec {
  name = "openexr-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/openexr/openexr/releases/download/v${version}/${name}.tar.gz"
      "mirror://savannah/openexr/${name}.tar.gz"
    ];
    sha256 = "8f9a5af6131583404261931d9a5c83de0a425cb4b8b25ddab2b169fbf113aecd";
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
