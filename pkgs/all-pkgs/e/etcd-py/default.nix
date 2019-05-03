{ stdenv
, buildPythonPackage
, fetchFromGitHub

, pytz
, requests
}:

let
  version = "2.0.8";
in
buildPythonPackage {
  name = "etcd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "dsoprea";
    repo = "PythonEtcdClient";
    rev = version;
    sha256 = "87276a422d2d057ee4223eaa7c75ad36c8850257208f0f131bd1f8e4cdb29fe7";
  };

  postPatch = ''
    sed -i 's,==.*,,' etcd/resources/requirements.txt
  '';

  buildInputs = [
    pytz
    requests
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
