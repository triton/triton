{ stdenv
, python2Packages
, python3Packages
}:

let
  pythonPackages = python3Packages;
  version = "52";
in
pythonPackages.buildPythonPackage rec {
  name = "diffoscope-${version}";

  src = pythonPackages.fetchPyPi {
    package = "diffoscope";
    inherit version;
    sha256 = "fbe3d75b5d82e90288a482b72c7ce0a5972f0d033ef9618ebc9c579578ea6315";
  };

  propagatedBuildInputs = [
    pythonPackages.libarchive-c
    pythonPackages.python-magic
  ];

  doCheck = false;

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
