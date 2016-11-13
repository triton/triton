{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.2.1";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "2493ead7dc10ac019e7ec803b2afb326e5c26b44132c5d15d1e870dc21f9f0ba";
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
