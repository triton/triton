{ stdenv
, fetchTritonPatch
, fetchurl
}:

let
  version = "0.2.1";
in
stdenv.mkDerivation rec {
  name = "yaml-${version}";

  src = fetchurl {
    url = "https://pyyaml.org/download/libyaml/yaml-${version}.tar.gz";
    multihash = "QmVkw7QLMhv2xSFfYnhA1iZHjKZoamXyXevXK1ZfwoHBic";
    hashOutput = false;
    sha256 = "78281145641a080fb32d6e7a87b9c0664d611dcb4d542e90baf731f51cbb59cd";
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
