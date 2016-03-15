{ stdenv
, fetchurl
, pythonPackages

, librsync
}:

pythonPackages.buildPythonPackage rec {
  name = "duplicity-${version}";
  version = "0.7.06";

  src = fetchurl {
    url = "http://code.launchpad.net/duplicity/0.7-series/${version}/+download/${name}.tar.gz";
    sha256 = "133zdi1rbiacvzjys7q3vjm7x84kmr51bsgs037rjhw9vdg5jx80";
  };

  pythonPath = [
    pythonPackages.lockfile
  ];

  nativeBuildInputs = [
    pythonPackages.wrapPython
  ];

  buildInputs = [
    librsync
    pythonPackages.lockfile
  ];

  doCheck = false;

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
