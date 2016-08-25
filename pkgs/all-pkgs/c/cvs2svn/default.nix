{ stdenv
, buildPythonPackage
, fetchurl
, isPy3k

, bazaar
, git
, subversion
}:

buildPythonPackage rec {
  name = "cvs2svn-2.4.0";

  src = fetchurl {
    url = "http://cvs2svn.tigris.org/files/documents/1462/49237/${name}.tar.gz";
    multihash = "QmeaAWRW5WMx9nLx23biyYteSm87VQdTTzdTz3cp3cpbY6";
    sha256 = "a6677fc3e7b4374020185c61c998209d691de0c1b01b53e59341057459f6f116";
  };

  buildInputs = [
    bazaar
    git
    subversion
  ];

  disabled = isPy3k;

  meta = with stdenv.lib; {
    description = "CVS to Subversion/git/Bazaar/Mercurial repository converter";
    homepage = http://cvs2svn.tigris.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
