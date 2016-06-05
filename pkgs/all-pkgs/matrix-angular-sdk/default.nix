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
    owner = "matrix-org";
    repo = "matrix-angular-sdk";
    rev = "v${version}";
    sha256 = "cdf6ca2afcafe26b12186a02f5e0c00ffd20aa0fda7f38da1837c17df0406674";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
