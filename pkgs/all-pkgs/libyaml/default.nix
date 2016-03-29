{ stdenv
, fetchpatch
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
    (fetchpatch {
      name = "libyaml-CVE-2014-9130.patch";
      url = "http://bitbucket.org/xi/libyaml/commits/2b915675/raw/";
      sha256 = "1vrkga2wk060wccg61c2mj5prcyv181qikgdfi1z4hz8ygmpvl04";
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
