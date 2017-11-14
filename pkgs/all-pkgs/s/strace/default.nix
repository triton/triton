{ stdenv
, fetchurl
, perl

, libunwind
}:

let
  version = "4.20";
in
stdenv.mkDerivation rec {
  name = "strace-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/strace/strace/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5bf3148dd17306a42566f7da17368fdd781afa147db05ea63a4ca2b50f58c523";
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
