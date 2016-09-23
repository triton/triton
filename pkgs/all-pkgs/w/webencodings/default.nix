{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.5";
in
buildPythonPackage rec {
  name = "webencodings-${version}";

  src = fetchPyPi {
    package = "webencodings";
    inherit version;
    sha256 = "a5c55ee93b24e740fe951c37b5c228dccc1f171450e188555a775261cce1b904";
  };

  meta = with stdenv.lib; {
    description = "Character encoding for the web";
    homepage = https://github.com/gsnedders/python-webencodings;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
