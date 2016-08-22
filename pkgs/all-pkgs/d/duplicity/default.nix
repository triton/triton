{ stdenv
, buildPythonPackage
, fetchurl

, librsync
, lockfile
}:

let
  version = "0.7.10";
in
buildPythonPackage rec {
  name = "duplicity-${version}";

  src = fetchurl {
    url = "https://code.launchpad.net/duplicity/0.7-series/${version}/"
      + "+download/${name}.tar.gz";
    sha256 = "485fef15526d163c061e00ec08de216cf7d652e67d41de5dc3bed9fb42214842";
  };

  buildInputs = [
    librsync
  ];

  propagatedBuildInputs = [
    lockfile
  ];

  meta = with stdenv.lib; {
    description = "Encrypted bandwidth-efficient backup using the rsync algorithm";
    homepage = "http://www.nongnu.org/duplicity";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
