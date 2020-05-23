{ stdenv
, cmake
, fetchurl
, lib

, version
}:

let
  sha256s = {
    "1.4.5" = "98e91c7c6bf162bf90e4e70fdbc41a8188b9fa8de5ad840c401198014406ce9e";
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
