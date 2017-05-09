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
    sha256 = "81e6da2e679c0235ef42c6f4054045603e12e51850d979cba9c2d4fe06723131";
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
