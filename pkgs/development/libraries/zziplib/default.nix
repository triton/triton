{ stdenv
, fetchFromGitHub
, lib

, perl
, python
, xmlto
, zip
, zlib
}:

let
  version = "0.13.67";
in
stdenv.mkDerivation rec {
  name = "zziplib-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "gdraheim";
    repo = "zziplib";
    rev = "v${version}";
    sha256 = "ea26e0f197138a30318955a62c644503e48fe8ef4385325152434ef386fd1385";
  };

  buildInputs = [
    perl
    python
    xmlto
    zip
    zlib
  ];

  postPatch = ''
    sed -i configure \
      -e 's/--export-dynamic//'
  '';

  doCheck = true;
  checkParallel = false;

  meta = with lib; {
    description = "Library to extract data from files archived in a zip file";
    homepage = http://zziplib.sourceforge.net/;
    license = with licenses; [
      lgpl2Plus
      mpl11
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
