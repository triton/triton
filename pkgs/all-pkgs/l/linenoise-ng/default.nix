{ stdenv
, cmake
, fetchFromGitHub
, ninja
}:

let
  date = "2017-06-28";
  rev = "4754bee2d8eb3c4511e6ac87cac62255b2011e2f";
in
stdenv.mkDerivation {
  name = "linenoise-ng-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "arangodb";
    repo = "linenoise-ng";
    inherit rev;
    sha256 = "ae1ce228a2d56cc6474928d68993cc63b4ab7581f4812b0fa28d5a3cca2f263f";
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
