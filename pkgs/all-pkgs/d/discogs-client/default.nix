{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, oauthlib
, requests
, six
}:

let
  version = "2.2.2";
in
buildPythonPackage rec {
  name = "discogs-client-${version}";

  src = fetchPyPi {
    package = "discogs-client";
    inherit version;
    sha256 = "aeae43fb9281e27c580d1bcd484e6c309f4f3a05af3908016ee3363786ef43d8";
  };

  propagatedBuildInputs = [
    oauthlib
    requests
    six
  ];

  meta = with lib; {
    description = "Official Python API client for Discogs";
    homepage = https://github.com/discogs/discogs_client/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
