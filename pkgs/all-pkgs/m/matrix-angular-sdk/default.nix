{ stdenv
, buildPythonPackage
, fetchFromGitHub
}:

let
  version = "0.6.8";
in
buildPythonPackage {
  name = "matrix-angular-sdk-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "matrix-org";
    repo = "matrix-angular-sdk";
    rev = "v${version}";
    sha256 = "fb46ea9a24fd067ef3723b3db05cc19ba3f10e097353f9c8bf2783fbc63a8938";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
