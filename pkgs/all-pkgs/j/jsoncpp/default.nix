{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "b8cb8889aab726a35c49472228256f7bb1d44388";
  date = "2020-05-07";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "08e15ddd4e5ae9b89a485c672648c37975294928266dfe7110762a59cf8228fe";
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
