{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "2baad4923e6d9a7e09982cfa4b1c5fd0b67ebd87";
  date = "2018-07-14";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "1efe942bcba43ef3814c8cb93fea25b467e822031e6cd86ae373dc648321e1cc";
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
