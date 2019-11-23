{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "stress-ng-0.10.11";

  src = fetchurl {
    url = "https://kernel.ubuntu.com/~cking/tarballs/stress-ng/${name}.tar.xz";
    sha256 = "ec41d375d1ae61862b00a939a5263791c8c8fdb262ad14ea204944df4ca140f1";
  };

  makeFlags = [
    "BINDIR=${placeholder "bin"}/bin"
    "MANDIR=${placeholder "man"}/share/man/man1"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "JOBDIR=$TMPDIR"
      "BASHDIR=$TMPDIR"
    )
  '';

  outputs = [
    "bin"
    "man"
  ];

  meta = with lib; {
    description = "Fast real-time lossless compression algorithm";
    homepage = http://www.zstd.net/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
