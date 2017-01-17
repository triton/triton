{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://gnu/gperf/gperf-${version}.tar.gz"
  ];

  version = "3.1";
in
stdenv.mkDerivation rec {
  name = "gperf-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "588546b945bba4b70b6a3a616e80b4ab466e3f33024a352fc2198112cdbb3ae2";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "EDEB 87A5 00CC 0A21 1677  FBFD 93C0 8C88 4710 97CD";
      inherit (src) outputHashAlgo;
      outputHash = "588546b945bba4b70b6a3a616e80b4ab466e3f33024a352fc2198112cdbb3ae2";
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
