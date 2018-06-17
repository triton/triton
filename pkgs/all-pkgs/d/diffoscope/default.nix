{ stdenv
, buildPythonPackage
, fetchPyPi

, libarchive-c
, python-magic
}:

let
  version = "96";
in
buildPythonPackage rec {
  name = "diffoscope-${version}";

  src = fetchPyPi {
    package = "diffoscope";
    inherit version;
    sha256 = "e2d067f540e11aa690f546bed1cafa8081a3d97d1192e05c7cc3c78aba70c6f4";
  };

  postPatch = /* Fix invalid encoding in README */ ''
    sed -i setup.py \
      -e '/long_description/d'
  '';

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
