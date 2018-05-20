{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
, makeWrapper

, parted
, wxGTK
}:

let
  version = "3.2.1";
in
stdenv.mkDerivation rec {
  name = "woeusb-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "slacka";
    repo = "woeusb";
    rev = "v${version}";
    sha256 = "5382198d4c7b1cbc9819c53baef8a80c8fdff45f1898e6faeff8df94552aa0d9";
  };

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  buildInputs = [
    wxGTK
  ];

  preFixup = ''
    wrapProgram "$out"/bin/woeusb \
      --prefix 'PATH' : '${parted}/bin'
  '';

  meta = with lib; {
    description = "Tool that creates a usb windows installer from an iso/dvd";
    homepage = https://github.com/slacka/WoeUSB;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

