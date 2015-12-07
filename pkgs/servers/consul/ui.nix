{ stdenv, fetchurl, goPackages, unzip }:

let
  version = stdenv.lib.replaceStrings ["v"] [""] goPackages.consul.rev;
in
stdenv.mkDerivation {
  name = "consul-ui-${version}";

  src = fetchurl {
    url = "https://releases.hashicorp.com/consul/${version}/consul_${version}_web_ui.zip";
    sha256 = "1c1fqg032h6c9hs2ih4ralrldgvxdl73679kavz2wjmva3pfgibk";
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
    maintainers = with maintainers; [ cstrahan wkennington ];
    license     = licenses.mpl20;
    platforms   = platforms.unix;
  };
}
