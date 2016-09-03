{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

stdenv.mkDerivation {
  name = "double-conversion-2016-07-11";

  src = fetchFromGitHub {
    version = 1;
    owner = "google";
    repo = "double-conversion";
    rev = "25166c3505aedb57a12301a37e2e2ad1d4e7a326";
    sha256 = "7040327727811a1010d4fb5f9832dfeb96c0b405a51fdc12b60c11819cfbecc4";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
