{ stdenv
, buildPythonPackage
, fetchPyPi

, file
}:

let
  version = "0.4.12";
in
buildPythonPackage {
  name = "python-magic-${version}";

  src = fetchPyPi {
    package = "python-magic";
    inherit version;
    sha256 = "a04b20900100884d4fce40a767182a16fcb9d10756c67cdc21f5fa610b7c9d3c";
  };

  postPatch = ''
    grep -r 'CDLL(dll)' | awk -F: '{print $1}' | sort | uniq | xargs -n 1 -P $NIX_BUILD_CORES \
      sed -i 's,CDLL(dll),CDLL("${file}/lib/libmagic.so"),g'
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
