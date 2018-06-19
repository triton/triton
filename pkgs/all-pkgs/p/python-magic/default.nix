{ stdenv
, buildPythonPackage
, fetchPyPi

, file
}:

let
  version = "0.4.15";
in
buildPythonPackage {
  name = "python-magic-${version}";

  src = fetchPyPi {
    package = "python-magic";
    inherit version;
    sha256 = "f3765c0f582d2dfc72c15f3b5a82aecfae9498bd29ca840d72f37d7bd38bfcd5";
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
