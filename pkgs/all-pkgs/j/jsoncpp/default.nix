{ stdenv
, fetchFromGitHub
, meson
, ninja
}:

let
  rev = "d61cddedac68f6dd3991d285045a23aeb253aa53";
  date = "2017-10-29";
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

  meta = with stdenv.lib; {
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
