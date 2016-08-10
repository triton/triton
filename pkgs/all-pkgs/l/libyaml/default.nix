{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libyaml-${version}";
  version = "0.1.6";

  src = fetchurl {
    url = "http://pyyaml.org/download/libyaml/yaml-${version}.tar.gz";
    sha256 = "0j9731s5zjb8mjx7wzf6vh7bsqi38ay564x6s9nri2nh9cdrg9kx";
  };

  patches = [
    (fetchTritonPatch {
      rev = "5f0bea0839c25b76893bdfccb73df7646a5198ab";
      file = "libyaml/CVE-2014-9130.patch";
      sha256 = "30546a280c4f9764a93ff5f4f88671a02222e9886e7f63ee19aebf1b2086a7fe";
    })
  ];

  meta = with stdenv.lib; {
    homepage = http://pyyaml.org/;
    description = "A YAML 1.1 parser and emitter written in C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
