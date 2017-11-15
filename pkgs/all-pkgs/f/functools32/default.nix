{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
}:

let
  version = "3.2.3-2";
in
buildPythonPackage {
  name = "functools32-${version}";

  src = fetchPyPi {
    package = "functools32";
    inherit version;
    sha256 = "f6253dfbe0538ad2e387bd8fdfd9293c925d63553f5813c4e587745416501e6d";
  };

  # Python 3 backport to Python 2.
  disabled = isPy3;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
