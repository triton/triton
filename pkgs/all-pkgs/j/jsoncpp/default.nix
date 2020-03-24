{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "3beb37ea14aec1bdce1a6d542dc464d00f4a6cec";
  date = "2020-02-13";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "69ab7cf556468dbbfa52dd4c3eb921cd8e621621c925b054493b8eaf9441390c";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = with lib; {
    description = "A simple API to manipulate JSON data in C++";
    homepage = https://github.com/open-source-parsers/jsoncpp;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
