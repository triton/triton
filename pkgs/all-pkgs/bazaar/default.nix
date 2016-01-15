{ stdenv
, fetchurl

, python2
, python2Packages
}:

stdenv.mkDerivation rec {
  name = "bazaar-${version}";
    versionMajor = "2.6";
    versionMinor = "0";
    version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "http://launchpad.net/bzr/${versionMajor}/${version}/+download/bzr-${version}.tar.gz";
    sha256 = "1c6sj77h5f97qimjc14kr532kgc0jk3wq778xrkqi0pbh9qpk509";
  };

  patches = [
    # Bazaar can't find the certificates alone
    ./add_certificates.patch
  ];

  postPatch = ''
    # Bazaar can't find the certificates alone
    substituteInPlace bzrlib/transport/http/_urllib2_wrappers.py \
      --subst-var-by certPath /etc/ssl/certs/ca-certificates.crt
  '';

  buildInputs = [
    python2
    python2Packages.paramiko
    python2Packages.pycurl
    python2Packages.wrapPython
  ];

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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
