{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.5.5";
in
buildPythonPackage rec {
  name = "python-mpd2-${version}";

  src = fetchPyPi {
    package = "python-mpd2";
    inherit version;
    sha256 = "310e738c4f7ce5b5b10394ec3f182c5240dd3ec55ec59a375924c8004fbb5e51";
  };

  meta = with lib; {
    description = "Python client interface for the Music Player Daemon";
    homepage = https://github.com/Mic92/python-mpd2;
    license = with licenses; [
      gpl3
      lgpl3
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
