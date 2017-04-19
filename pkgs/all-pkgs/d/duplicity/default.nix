{ stdenv
, buildPythonPackage
, fetchurl

, librsync
, lockfile
}:

let
  version = "0.7.12";
in
buildPythonPackage rec {
  name = "duplicity-${version}";

  src = fetchurl {
    url = "https://code.launchpad.net/duplicity/0.7-series/${version}/"
      + "+download/${name}.tar.gz";
    multihash = "QmYoNVYBk3TK3cwfGwBRjwmjyGA2aR2aj1HzTGF56Epeq8";
    sha256 = "11cbad44a90891af1bf9e294260ba7c21a1660ccd3ab2c6e736ba74ac5cf0fe6";
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
