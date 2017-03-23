{ stdenv
, buildPythonPackage
, fetchPyPi

, dnspython
, urllib3
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "0.4.5";
in
buildPythonPackage {
  name = "python-etcd-${version}";

  src = fetchPyPi {
    package = "python-etcd";
    inherit version;
    sha256 = "f1b5ebb825a3e8190494f5ce1509fde9069f2754838ed90402a8c11e1f52b8cb";
  };

  buildInputs = [
    dnspython
    urllib3
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
