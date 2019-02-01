{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "0c1cc6e1a373dc58e2599ec7dd68b2e6b863990a";
  date = "2019-01-20";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "ed7ff4134be5d8d326dbca3e61f42a5a3ce26d7af002a75adc53a0e467885134";
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
