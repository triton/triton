{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "313a0e4c340253f3ad2c7897b54fad9a8040847c";
  date = "2018-02-14";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "9761ced635cbd54caf3aa68ba4e6230a1b8c3b35b084071d9ae5dcb26a648235";
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
