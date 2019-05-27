{ stdenv
, fetchurl
, perl

, elfutils
, libunwind
}:

let
  version = "5.1";
in
stdenv.mkDerivation rec {
  name = "strace-${version}";

  src = fetchurl {
    url = "https://github.com/strace/strace/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "f5a341b97d7da88ee3760626872a4899bf23cf8dee56901f114be5b1837a9a8b";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    elfutils
    libunwind
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "296D 6F29 A020 808E 8717  A884 2DB5 BD89 A340 AEB7";
      };
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
