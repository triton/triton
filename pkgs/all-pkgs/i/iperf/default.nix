{ stdenv
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
      version = "3.1.3";
      multihash = "QmPLdT2JXCwsVPv6Fhr2ruSFfRPB5FBydjUWJ63EsabNBT";
      sha256 = "e34cf60cffc80aa1322d2c3a9b81e662c2576d2b03e53ddf1079615634e6f553";
    };
  };

  inherit (stdenv.lib)
    optionalString;

  inherit (sources."${channel}")
    version
    multihash
    sha256;
in
stdenv.mkDerivation rec {
  name = "iperf-${version}";

  src = fetchurl {
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
