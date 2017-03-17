{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive-c
, python-magic
}:

let
  version = "80";
in
buildPythonPackage rec {
  name = "diffoscope-${version}";

  src = fetchPyPi {
    package = "diffoscope";
    inherit version;
    sha256 = "3a1b8060ee3984d912940239a2f9906087297dcbe929c5bb85f0108fc0160ef6";
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
