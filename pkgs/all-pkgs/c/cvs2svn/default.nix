{ stdenv
, buildPythonPackage
, fetchurl
, isPy3

, bazaar
, git
, subversion
}:

buildPythonPackage rec {
  name = "cvs2svn-2.5.0";

  src = fetchurl {
    url = "http://cvs2svn.tigris.org/files/documents/1462/49543/${name}.tar.gz";
    multihash = "QmQeNRR2puhCXfvTCn8zQF3atvsW4ofi34zh3qeNkDs8KM";
    hashOutput = false;
    sha256 = "6409d118730722f439760d41c08a5bfd05e5d3ff4a666050741e4a5dc2076aea";
  };

  buildInputs = [
    bazaar
    git
    subversion
  ];

  disabled = isPy3;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrl = "http://cvs2svn.tigris.org/files/documents/1462/49544/${name}.tar.gz.asc";
        pgpKeyFingerprints = [
          # Michael Haggerty
          "5B31 41FB 0C48 B038 563E  1D93 C20F 66AD 1C1F 9809"
        ];
      };
      failEarly = true;
    };
  };

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
