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

  version = "1.7.0";
in
stdenv.mkDerivation rec {
  name = "openh264-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "cisco";
    repo = "openh264";
    rev = "v${version}";
    sha256 = "8a3e0bf2c5b8a2b3684ddb24b4d3422b31e1cb34ec3ffb193c2ade67b9900f08";
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
