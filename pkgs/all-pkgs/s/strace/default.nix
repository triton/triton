{ stdenv
, fetchurl
, perl

, elfutils
, libunwind
}:

let
  version = "5.2";
in
stdenv.mkDerivation rec {
  name = "strace-${version}";

  src = fetchurl {
    url = "https://github.com/strace/strace/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d513bc085609a9afd64faf2ce71deb95b96faf46cd7bc86048bc655e4e4c24d2";
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
