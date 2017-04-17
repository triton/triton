{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.1.5";
in
buildPythonPackage {
  name = "zbase32-${version}";

  src = fetchPyPi {
    package = "zbase32";
    inherit version;
    sha256 = "9b25c34ba586cbbad4517af516e723599a6f38fc560f4797855a5f3051e6422f";
  };

  postPatch = ''
    sed -i "/\['pyutil'\]/d" setup.py
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
