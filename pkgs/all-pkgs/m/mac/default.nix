{ stdenv
, fetchurl
, lib
, unzip
}:

let
  version = "4.4.4";
in
stdenv.mkDerivation rec {
  name = "mac-${version}";

  src = fetchurl {
    url = "https://monkeysaudio.com/files/"
      + "MAC_SDK_${lib.replaceStrings ["."] [""] version}.zip";
    multihash = "QmcjNgUgB1PfoH5gjzxdvXTCnyZEWTHNJdHzVUXKUu9HH2";
    sha256 = "e2af2e9d57b7cd66e5d6525fcd8fcde3839f48a623d31aca22a92cb0d0ea297c";
  };

  nativeBuildInputs = [
    unzip
  ];

  srcRoot = ".";

  preUnpack = ''
    mkdir src/
    cd src/
  '';

  makefile = "Source/Projects/NonWindows/Makefile";

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with lib; {
    description = "Monkey's Audio Codecs";
    homepage = https://www.monkeysaudio.com/index.html;
    license = licenses.free;  # https://www.monkeysaudio.com/license.html
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
