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
    version = 3;
    owner = "arangodb";
    repo = "linenoise-ng";
    inherit rev;
    sha256 = "d07d9d44c22bf6ea80fa2145214ed1f319a058628a92537aabb38f95dd28f6eb";
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
