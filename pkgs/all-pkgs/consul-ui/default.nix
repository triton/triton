{ stdenv
, fetchurl
, goPackages
, unzip
}:

let
  version = stdenv.lib.replaceStrings ["v"] [""] goPackages.consul.rev;
in

stdenv.mkDerivation {
  name = "consul-ui-${version}";

  src = fetchurl {
    url = "https://releases.hashicorp.com/consul/${version}/consul_${version}_web_ui.zip";
    sha256 = "5f8841b51e0e3e2eb1f1dc66a47310ae42b0448e77df14c83bb49e0e0d5fa4b7";
  };

  preUnpack = ''
    mkdir -p tmp
    cd tmp
  '';

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  doConfigure = false;
  doBuild = false;

  installPhase = ''
    mkdir -p $out
    cp -a * $out
  '';

  meta = with stdenv.lib; {
    homepage    = http://www.consul.io/;
    description = "A tool for service discovery, monitoring and configuration";
    maintainers = with maintainers; [
      wkennington
    ];
    license = licenses.mpl20;
    platforms = with platforms;
      x86_64-linux;
  };
}
