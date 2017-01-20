{ stdenv
, fetchurl

, channel
}:

let
  tarballUrls = version: [
    "mirror://gnu/gperf/gperf-${version}.tar.gz"
  ];

  source = (import ./sources.nix)."${channel}";

  inherit (source)
    version
    sha256;
in
stdenv.mkDerivation rec {
  name = "gperf-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    inherit sha256;
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls (source.newVersion or version);
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "EDEB 87A5 00CC 0A21 1677  FBFD 93C0 8C88 4710 97CD";
      inherit (src) outputHashAlgo;
      outputHash = source.newSha256 or sha256;
    };
  };

  meta = with stdenv.lib; {
    description = "Perfect hash function generator";
    homepage = http://www.gnu.org/software/gperf/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
