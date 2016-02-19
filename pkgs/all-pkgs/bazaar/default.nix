{ stdenv
, fetchTritonPatch
, fetchurl

, python2
, python2Packages
}:

stdenv.mkDerivation rec {
  name = "bazaar-${version}";
    versionMajor = "2.7";
    versionMinor = "0";
    version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "http://launchpad.net/bzr/${versionMajor}/${version}/+download/bzr-${version}.tar.gz";
    sha256 = "1cysix5k3wa6y7jjck3ckq3abls4gvz570s0v0hxv805nwki4i8d";
  };

  buildInputs = [
    python2
    python2Packages.paramiko
    python2Packages.pycurl
    python2Packages.wrapPython
  ];

  patches = [
    (fetchTritonPatch {
      rev = "f84914eb8e0780068f4d7fb4d7581f4ea1eede1a";
      file = "bazaar/bazaar-2.7-fix-cacert-path.patch";
      sha256 = "2246cacdcd83dbcb0d518eb2beb7a959830c6b13fa170437131170b1987ecf8d";
    })
  ];

  postPatch =
    /* Bazaar patch doesn't set the cacert path */ ''
      substituteInPlace bzrlib/transport/http/_urllib2_wrappers.py \
        --subst-var-by certPath /etc/ssl/certs/ca-certificates.crt
    '';

  installPhase = ''
    runHook 'preInstall'
    ${python2.interpreter} setup.py install --prefix=$out
    wrapPythonPrograms
    runHook 'postInstall'
  '';

  meta = with stdenv.lib; {
    description = "Bazaar is a next generation distributed version control system";
    homepage = http://bazaar-vcs.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
