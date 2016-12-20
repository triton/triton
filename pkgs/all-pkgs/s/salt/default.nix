{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, futures
, jinja2
#, m2crypto
, markupsafe
, msgpack-python
, openssl
, pycrypto
#, pygit2
, pyyaml
, pyzmq
, requests
#, systemd
, tornado
}:

let
  version = "2016.11.1";
in
buildPythonPackage rec {
  name = "salt-${version}";

  src = fetchPyPi {
    package = "salt";
    inherit version;
    sha256 = "00343e190dcf6dfa27dbec996d1161f7aef16cf99510b67970136cf24f092992";
  };

  postPatch = /* Salt looks for openssl in the same prefix */ ''
    sed -i salt/utils/rsax931.py \
      -e "s,find_library('crypto'),'${openssl}/lib/libcrypto.so',"
  '';

  propagatedBuildInputs = [
    futures
    jinja2
    markupsafe
    msgpack-python
    openssl
    pycrypto
    pyyaml
    pyzmq
    requests
    tornado
  ];

  meta = with lib; {
    description = "Distributed, remote execution & configuration management system";
    homepage = http://saltstack.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
