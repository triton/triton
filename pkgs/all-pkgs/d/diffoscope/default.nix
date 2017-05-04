{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive-c
, python-magic
}:

let
  version = "82";
in
buildPythonPackage rec {
  name = "diffoscope-${version}";

  src = fetchPyPi {
    package = "diffoscope";
    inherit version;
    sha256 = "e90c5d99a7c750c1f2c8baa5a34c8f2640d79d9c0837b8e10831bbc8ad350637";
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
