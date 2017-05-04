{ stdenv
, buildPythonPackage
, fetchPyPi

, file
}:

let
  version = "0.4.13";
in
buildPythonPackage {
  name = "python-magic-${version}";

  src = fetchPyPi {
    package = "python-magic";
    inherit version;
    sha256 = "604eace6f665809bebbb07070508dfa8cabb2d7cb05be9a56706c60f864f1289";
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
