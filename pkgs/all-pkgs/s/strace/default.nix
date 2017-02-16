{ stdenv
, fetchurl
, perl

, libunwind
}:

stdenv.mkDerivation rec {
  name = "strace-4.16";

  src = fetchurl {
    url = "mirror://sourceforge/strace/${name}.tar.xz";
    hashOutput = false;
    sha256 = "98487cb5178ec1259986cc9f6e2a844f50e5d1208c112cc22431a1e4d9adf0ef";
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
