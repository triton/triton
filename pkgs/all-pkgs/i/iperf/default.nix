{ stdenv
, fetchFromGitHub
, fetchurl

, openssl

, channel
}:

let
  sources = {
    "2" = {
      version = "2.0.12";
      sha256 = "367f651fb1264b13f6518e41b8a7e08ce3e41b2a1c80e99ff0347561eed32646";
    };
    "3" = {
      fetchzipVersion = 6;
      version = "3.6";
      sha256 = "bbdcadcd7588f309838f04ca681ef367361bec1ba1873a4669ef3db7693d13a1";
    };
  };

  inherit (stdenv.lib)
    optionals
    optionalString;

  source = sources."${channel}";

  inherit (source)
    version
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
        url = "mirror://sourceforge/iperf2/${name}.tar.gz";
        inherit sha256;
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
