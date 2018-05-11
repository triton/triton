{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

#, deluge-client
, requests
, six
}:

let
  version = "1.6.3";
in
buildPythonPackage rec {
  name = "autotorrent-${version}";

  src = fetchPyPi {
    package = "autotorrent";
    inherit version;
    sha256 = "5f13efd1d609f1532a69bca04f0338b5382a4b7fe468fcabd1e960f9c23ae5b5";
  };

  propagatedBuildInputs = [
    #deluge-client
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

