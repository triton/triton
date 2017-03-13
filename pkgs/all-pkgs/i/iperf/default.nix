{ stdenv
, fetchFromGitHub
, fetchurl

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
      fetchzipVersion = 2;
      version = "3.1.7";
      sha256 = "5133c033d68d72991cb0b07e7ca1aa82f123e51e971f9fb2f6dc92d904749816";
    };
  };

  inherit (stdenv.lib)
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
