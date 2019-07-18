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
  version = "118";
in
buildPythonPackage rec {
  name = "diffoscope-${version}";

  src = fetchPyPi {
    package = "diffoscope";
    inherit version;
    sha256 = "14d63a69822388e2929126f241b8f034913296069b556266c0dc4597fab0a5ff";
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
