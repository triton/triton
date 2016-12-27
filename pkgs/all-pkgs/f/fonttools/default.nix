{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.4.0";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "40bbe2a7a79f51757f5973a1a7d487d700987bb394d8611132a06f32fbc6a084";
  };

  meta = with stdenv.lib; {
    description = "Library for manipulating fonts";
    homepage = https://github.com/behdad/fonttools;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
