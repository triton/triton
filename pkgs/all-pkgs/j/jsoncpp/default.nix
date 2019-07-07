{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "3c32dca89214c03b107cc9d1c468000cff3f8127";
  date = "2019-07-02";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "628ecbe1f44c06d71bfa85fca06a1029407e465a80f162e657eae69102863571";
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
