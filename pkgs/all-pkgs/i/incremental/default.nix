{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "16.10.1";
in
buildPythonPackage rec {
  name = "incremental-${version}";

  src = fetchPyPi {
    package = "incremental";
    inherit version;
    sha256 = "14ad6b720ec47aad6c9caa83e47db1843e2b9b98742da5dda08e16a99f400342";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
