{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "2f227cb122584989a61278e93f9a26b1a7e3d1bf";
  date = "2017-12-23";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "c710bf96f2f77b27dff4eeb274939ef0e41e144854892b185356fe3b7cde9763";
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
