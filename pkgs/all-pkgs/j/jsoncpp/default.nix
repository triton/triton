{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "7c979e86610f48fa50e740854bcfce170b50fb46";
  date = "2017-11-16";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "b8618239505f9e587de4be7da1ad94f9b3e88284bfb6fa8ddd0139fe50975821";
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
