{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "80bc776bae74261742b7c2d0b8dc31ec1718ba4a";
  date = "2018-06-24";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "48ca28ba3b309090898cd415d37533c118ab929d460291d7ddc1cb0a7dfd96bc";
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
