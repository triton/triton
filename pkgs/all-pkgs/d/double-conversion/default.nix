{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2018-04-20";
  rev = "7a560cf769d9f108d7c09299f805823692a0f523";
in
stdenv.mkDerivation {
  name = "double-conversion-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "double-conversion";
    inherit rev;
    sha256 = "07cee67ea2d767bb900009b45a9adedcbf72ec82974c47ec45390b691381cb34";
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
