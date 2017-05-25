{ stdenv
, fetchurl
, perl

, libunwind
}:

stdenv.mkDerivation rec {
  name = "strace-4.17";

  src = fetchurl {
    url = "mirror://sourceforge/strace/${name}.tar.xz";
    hashOutput = false;
    sha256 = "81f35b085fbb3cfa806eb521a8522ac3406deaccfe121ce35064bad268237419";
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
