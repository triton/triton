{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
}:

let
  rev = "12325b814f00cc31c6ccdb7a17d058c4dbc55aed";
  date = "2019-07-22";
in
stdenv.mkDerivation rec {
  name = "jsoncpp-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "open-source-parsers";
    repo = "jsoncpp";
    inherit rev;
    sha256 = "b3cec3f01a35b56fdd09c16caf06ecdf8ddc2992a637c93c4843f4005fbf4b79";
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
