{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive-c
, python-magic
}:

let
  version = "62";
in
buildPythonPackage rec {
  name = "diffoscope-${version}";

  src = fetchPyPi {
    package = "diffoscope";
    inherit version;
    sha256 = "1f3de98304fe1020d2b9417f7e45818204760589e55f59145c1286c0f523eb88";
  };

  propagatedBuildInputs = [
    libarchive-c
    python-magic
  ];

  meta = with stdenv.lib; {
    description = "Perform in-depth comparison of files, archives, and directories";
    homepage = https://wiki.debian.org/ReproducibleBuilds;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
