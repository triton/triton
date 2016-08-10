{ stdenv
, fetchurl
}:

let
  name = "rfkill-0.5";

  baseTarballs = [
    "mirror://kernel/software/network/rfkill/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.xz") baseTarballs;
    allowHashOutput = false;
    sha256 = "e0ae3004215e39a6c5c36e0726558740728d16f67ebdb8bea621250f6091d86a";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") baseTarballs;
      pgpDecompress = true;
      pgpKeyFingerprint = "C0EB C440 F6DA 091C 884D  8532 E0F3 73F3 7BF9 099A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://wireless.kernel.org/en/users/Documentation/rfkill;
    description = "A tool to query, enable and disable wireless devices";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
