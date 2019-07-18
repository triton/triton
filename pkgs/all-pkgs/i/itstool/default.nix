{ stdenv
, buildPythonPackage
, fetchPyPi
, fetchTritonPatch
, lib

, libxml2
}:

let
  version = "2.0.6";
in
buildPythonPackage rec {
  name = "itstool-${version}";

  src = fetchPyPi {
    package = "itstool";
    inherit version;
    sha256 = "2f2a67c6cf525ada1cf437b8dda3bf5ad84b4cb172446011aa85c0542131d92b";
  };

  propagatedBuildInputs = [
    libxml2
  ];

  # Move our shared data to the correct directory
  postInstall = ''
    mv "$(toPythonPath "$out")"/usr/local/share "$out"
    rmdir "$(toPythonPath "$out")"/usr{/local,}
  '';

  # Fix references to /usr
  preFixup = ''
    grep -q '/usr/local/share' "$out"/bin/itstool
    sed -i "s,/usr\(\|/local\),$out,g" "$out"/bin/itstool
  '';

  meta = with lib; {
    homepage = http://itstool.org/;
    description = "XML to PO and back again";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
