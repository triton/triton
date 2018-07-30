{ stdenv
, buildPythonPackage
, fetchPyPi
, fetchTritonPatch
, lib

, libxml2
}:

let
  version = "2.0.4";
in
buildPythonPackage rec {
  name = "itstool-${version}";

  src = fetchPyPi {
    package = "itstool";
    inherit version;
    sha256 = "e62b224d679aaa5f445255eee9893917f5f0ef1023010b8b57c3634fc588829d";
  };

  propagatedBuildInputs = [
    libxml2
  ];

  patches = [
    (fetchTritonPatch {
      rev = "9a5628012d660812c9dbac289a5460d86a3cc908";
      file = "i/itstool/0001-Be-more-careful-about-libxml2-memory-management.patch";
      sha256 = "fb7ae169c80778de40944576983640cbf7c3511cceb37727697e6aee8af3200e";
    })
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
