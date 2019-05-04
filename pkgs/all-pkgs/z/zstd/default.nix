{ stdenv
, cmake
, fetchurl
, lib

, version
}:

let
  sha256s = {
    "1.4.0" = "7f323f0e0c18488748f3d9b2d4353f00e904ea2ccd0372ea04d7f77aa1156557";
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
