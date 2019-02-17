{ stdenv
, buildPythonPackage
, fetchFromGitHub
, lib

, deluge-client
, requests
, six
}:

buildPythonPackage rec {
  name = "autotorrent-2019-02-12";

  src = fetchFromGitHub {
    version = 6;
    owner = "JohnDoee";
    repo = "autotorrent";
    rev = "43d0150eb3509fc0df53a7228b77032b59cc371b";
    sha256 = "9934a8106c17962e0bb8c1ea3cc5b8561d7e5dd547d3ef902bed0d2465b5fa09";
  };

  propagatedBuildInputs = [
    deluge-client
    requests
    six
  ];

  meta = with lib; {
    description = "Matches torrents with files and gets them seeded";
    homepage = https://github.com/JohnDoee/autotorrent;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

