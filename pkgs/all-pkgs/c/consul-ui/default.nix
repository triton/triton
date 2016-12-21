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
    sha256 = "c9d2a6e1d1bb6243e5fd23338d92f5c71cdf0a4077f7fcc95fd81800fa1f42a9";
  };

  preUnpack = ''
    mkdir -p tmp
    cd tmp
  '';

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    mkdir -p $out
    cp -a * $out
  '';

  meta = with stdenv.lib; {
    description = "A tool for service discovery, monitoring and configuration";
    homepage    = http://www.consul.io/;
    license = licenses.mpl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
