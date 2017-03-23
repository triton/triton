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
    version = 2;
    owner = "dsoprea";
    repo = "PythonEtcdClient";
    rev = version;
    sha256 = "49229c429916f8788347ab372070d9ddc8cb15e6918eb5bb0b79ead962c5e27f";
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
