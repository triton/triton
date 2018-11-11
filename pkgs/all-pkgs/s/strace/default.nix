{ stdenv
, fetchurl
, perl

, elfutils
, libunwind
}:

let
  version = "4.25";
in
stdenv.mkDerivation rec {
  name = "strace-${version}";

  src = fetchurl {
    url = "https://github.com/strace/strace/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d685f8e65470b7832c3aff60c57ab4459f26ff89f07c10f92bd70ee89efac701";
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
