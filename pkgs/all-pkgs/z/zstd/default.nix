{ stdenv
, cmake
, fetchurl
, lib

, version
}:

let
  sha256s = {
    "1.3.8" = "293fa004dfacfbe90b42660c474920ff27093e3fb6c99f7b76e6083b21d6d48e";
  };
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchurl {
    url = "https://github.com/facebook/zstd/releases/download/v${version}/${name}.tar.gz";
    sha256 = sha256s."${version}";
  };

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
    )
  '';

  dontPatchShebangs = true;

  allowedReferences = [
    "out"
    stdenv.cc.libc
    stdenv.cc.libidn2
    stdenv.cc.libstdcxx
    stdenv.cc.cc
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
