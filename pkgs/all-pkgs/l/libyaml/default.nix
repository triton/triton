{ stdenv
, fetchTritonPatch
, fetchurl
}:

let
  version = "0.1.7";
in
stdenv.mkDerivation rec {
  name = "yaml-${version}";

  src = fetchurl {
    url = "http://pyyaml.org/download/libyaml/yaml-${version}.tar.gz";
    multihash = "QmeyiLzTi5ujorYnG5LhNHLA2o4unnicBzKQabmBmn2Z4S";
    sha256 = "8088e457264a98ba451a90b8661fcb4f9d6f478f7265d48322a196cec2480729";
  };

  meta = with stdenv.lib; {
    description = "A YAML 1.1 parser and emitter written in C";
    homepage = http://pyyaml.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
