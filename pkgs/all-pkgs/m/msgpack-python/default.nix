{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.4.8";
in
buildPythonPackage {
  name = "msgpack-python-${version}";

  src = fetchPyPi {
    package = "msgpack-python";
    inherit version;
    sha256 = "1a2b19df0f03519ec7f19f826afb935b202d8979b0856c6fb3dc28955799f886";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
