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
    version = 6;
    owner = "matrix-org";
    repo = "matrix-angular-sdk";
    rev = "v${version}";
    sha256 = "d504bcbf1aa8b01b13fbdb398a0ca8bbec470586b59f7f7bc04f5300e36c8856";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
