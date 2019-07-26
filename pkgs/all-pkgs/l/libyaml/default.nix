{ stdenv
, fetchTritonPatch
, fetchurl
}:

let
  version = "0.2.2";
in
stdenv.mkDerivation rec {
  name = "yaml-${version}";

  src = fetchurl {
    url = "https://pyyaml.org/download/libyaml/yaml-${version}.tar.gz";
    multihash = "QmSYUuYEKL3Rpmu77MBu5oyF8w6i94rdqErQdmk9DmEdDL";
    hashOutput = false;
    sha256 = "4a9100ab61047fd9bd395bcef3ce5403365cafd55c1e0d0299cde14958e47be9";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
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
