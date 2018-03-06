{ stdenv
, fetchFromGitHub
, fetchurl

, openssl

, channel
}:

let
  sources = {
    "2" = {
      version = "2.0.9";
      multihash = "QmVEsHmgJrz1vJM9oGaM5oStWsxYC19JyCW4QAUVQWvVKM";
      sha256 = "a5350777b191e910334d3a107b5e5219b72ffa393da4186da1e0a4552aeeded6";
    };
    "3" = {
      fetchzipVersion = 5;
      version = "3.5";
      sha256 = "b7af9389e9c33823964dd9900364fb77846867c00ba0cf8bbee55e7989fc248a";
    };
  };

  inherit (stdenv.lib)
    optionals
    optionalString;

  source = sources."${channel}";

  inherit (source)
    version
    multihash
    sha256;
in
stdenv.mkDerivation rec {
  name = "iperf-${version}";

  src =
    if source ? fetchzipVersion then
      fetchFromGitHub {
        version = source.fetchzipVersion;
        owner = "esnet";
        repo = "iperf";
        rev = version;
        inherit sha256;
      }
    else
      fetchurl {
        name = "${name}.tar.gz";
        url = "https://iperf.fr/download/source/${name}-source.tar.gz";
        inherit multihash sha256;
      };

  buildInputs = optionals (channel == "3") [
    openssl
  ];

  postInstall = optionalString (channel == "3") ''
    ln -s iperf3 $out/bin/iperf
  '';

  meta = with stdenv.lib; {
    homepage = http://software.es.net/iperf/;
    description = "Tool to measure IP bandwidth using UDP or TCP";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
