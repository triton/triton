{ stdenv
, lib
, fetchFromGitHub
}:

let
  version = "2.11.4";
in
stdenv.mkDerivation rec {
  name = "libimagequant-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "ImageOptim";
    repo = "libimagequant";
    rev = version;
    sha256 = "a707b25a0d8497cca63c1283f5bcae0a915741e2515a1d60ca388e938a2168b0";
  };

  postPatch = ''
    patchShebangs configure
  '';

  buildFlags = [
    "shared"
  ];

  installPhase = ''
    mkdir -p "$out"/{include,lib}
    cp libimagequant.so.* "$out"/lib
    ln -sv libimagequant.so.* "$out"/lib/libimagequant.so
    cp libimagequant.h "$out"/include
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
