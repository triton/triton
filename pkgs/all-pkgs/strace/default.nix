{ stdenv
, fetchurl
, perl

, libunwind
}:

let
  version = "4.12";
in
stdenv.mkDerivation rec {
  name = "strace-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/strace/${version}/${name}.tar.xz";
    allowHashOutput = false;
    multihash = "QmZ1WtnKojqG2NQb2G87puKio8d4jvBQAUT1CRvcmywLXt";
    sha256 = "51144b78cb9ba22211b95a5aafe0af3694c0d575b25975d80ca9dd4dfd7c1e59";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    libunwind
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "296D 6F29 A020 808E 8717  A884 2DB5 BD89 A340 AEB7";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A system call tracer for Linux";
    homepage = http://strace.sourceforge.net/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
