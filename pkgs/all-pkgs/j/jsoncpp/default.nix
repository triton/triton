{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "5b91551f3944d69e0090d6b6528852207de78078";
  date = "2019-04-24";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "3ad3c35ccbc3c01e272909dcb5028b4f621603ec1f58cd64e06076bd0eb18ec0";
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
