{ stdenv
, lib
, fetchFromGitHub
}:

let
  version = "2.12.1";
in
stdenv.mkDerivation rec {
  name = "libimagequant-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ImageOptim";
    repo = "libimagequant";
    rev = version;
    sha256 = "437433a53e69b791ee1cdac5c6c58d63a53d0d7e8443df3606f28c093e0df22b";
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
