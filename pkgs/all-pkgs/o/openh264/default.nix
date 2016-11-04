{ stdenv
, fetchFromGitHub
, fetchurl
, lib

, nasm
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    elem
    optionals
    optionalString
    platforms;

  version = "1.6.0";
in
stdenv.mkDerivation rec {
  name = "openh264-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "cisco";
    repo = "openh264";
    rev = "v${version}";
    sha256 = "c3138b4d29344e47d1ec4c3e208dffa4959040e5317c8b22c4314702e04aeb79";
  };

  nativeBuildInputs = [
    nasm
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  makeFlags = optionals (elem targetSystem platforms.bit64) [
    "ENABLE64BIT=Yes"
  ];

  meta = with lib; {
    description = "A library for encoding & decoding h.264/AVC";
    homepage = http://www.openh264.org;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
