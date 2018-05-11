{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.4.0";
in
buildPythonPackage {
  name = "deluge-client-${version}";

  src = fetchPyPi {
    package = "deluge-client";
    inherit version;
    sha256 = "86979ebcb9f1f991554308e88c7a57469cbf339958b44c71cbdcba128291b043";
  };

  meta = with lib; {
    description = "A very lightweight pure-python Deluge RPC Client";
    homepage = https://github.com/JohnDoee/deluge-client;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

