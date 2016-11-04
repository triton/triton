{ stdenv
, fetchFromGitHub
, wxGTK
}:

stdenv.mkDerivation {
  name = "winusb-2016-11-03";

  src = fetchFromGitHub {
    version = 2;
    owner = "slacka";
    repo = "WinUSB";
    rev = "52d4c2d8bcdf6e9483745574afd5abaed8146be7";
    sha256 = "b133366b061f6f6f4eac2de507dbdb292ae3e1b1135ce064ced6884e0d55a4ad";
  };

  buildInputs = [
    wxGTK
  ];

  meta = with stdenv.lib; {
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
