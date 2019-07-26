{ stdenv
, cmake
, fetchurl
, lib

, version
}:

let
  sha256s = {
    "1.4.2" = "12730983b521f9a604c6789140fcb94fadf9a3ca99199765e33c56eb65b643c9";
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
  ] ++ stdenv.cc.runtimeLibcLibs;

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
