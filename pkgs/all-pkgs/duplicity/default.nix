{ stdenv
, buildPythonPackage
, fetchurl

, librsync
, lockfile
}:

let
  version = "0.7.08";
in
buildPythonPackage rec {
  name = "duplicity-${version}";

  src = fetchurl {
    url = "https://code.launchpad.net/duplicity/0.7-series/${version}/+download/${name}.tar.gz";
    sha256 = "d6d0b25ac2a39daa32f269a9bf6b3ea6d9202dcab388fa91bd645868defb0f17";
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
