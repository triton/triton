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
    version = 6;
    owner = "gdraheim";
    repo = "zziplib";
    rev = "v${version}";
    sha256 = "ab38ed9a193d5991c745b4d350d0ad3fa277895ec724b31ed843f793a651412f";
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
