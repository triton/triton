{ stdenv
, fetchurl
, lib

, version
}:

let
  sha256s = {
    "1.0.3" = "0136ed31d129df55dc47eeb24c59336514ba72e1cced0973687a0c7b21a3ddf7";
    "1.0.7" = "992393e77eacd48120d4dc9c2ddc36eb107f3c7ca14ce216803b1cefd16b83a5";
  };
in
stdenv.mkDerivation {
  name = "brotli-${version}";

  src = fetchurl {
    url = "https://github.com/triton/brotli/releases/download/v${version}/brotli-${version}.tar.xz";
    hashOutput = false;
    sha256 = sha256s."${version}";
  };

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "A generic-purpose lossless compression algorithm and tool";
    homepage = https://github.com/google/brotli;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
