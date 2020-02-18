{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

#, defusedxml
, libarchive-c
#. progressbar
, python-magic
}:

let
  version = "136";
in
buildPythonPackage rec {
  name = "diffoscope-${version}";

  src = fetchPyPi {
    package = "diffoscope";
    inherit version;
    sha256 = "0d6486d6eb6e0445ba21fee2e8bdd3a366ce786bfac98e00e5a95038b7815f15";
  };

  postPatch = /* Fix invalid encoding in README */ ''
    sed -i setup.py \
      -e '/long_description/d'
  '';

  propagatedBuildInputs = [
    #argcomplete
    #binwalk
    #defusedxml
    #guestfs
    #jsondiff
    libarchive-c
    #progressbar
    #pyxattr
    #pypdf2
    #python-debian
    python-magic
    #rpm-python
    #tlsh
  ];

  meta = with lib; {
    description = "Compares files, archives, and directories in-depth";
    homepage = https://diffoscope.org/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
