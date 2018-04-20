{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "02211117f18b9469d632b71f112cf3211331587d";
  date = "2018-04-19";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "023e9e2b57b7660b2d7e4fe5920b3e7732ebe36867ac28184c1e89c54fe4fb2c";
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
