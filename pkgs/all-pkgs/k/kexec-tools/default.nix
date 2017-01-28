{ stdenv
, fetchurl

, xz
, zlib
}:

let
  name = "kexec-tools-2.0.14";

  tarballUrls = [
    "mirror://kernel/linux/utils/kernel/kexec/${name}.tar"
    "http://horms.net/projects/kexec/kexec-tools/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "ffb2e7e99d9d08754c6bc1922aed3c000094f318665d82a72ecc76c4ff1c0dc6";
  };

  buildInputs = [
    xz
    zlib
  ];

  configureFlags = [
    "--with-lzma"
    "--with-zlib"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sign") tarballUrls;
      pgpDecompress = true;
      pgpKeyFingerprint = "E27C D9A1 F5AC C2FF 4BFE  7285 D7CF 6469 6A37 4FBE";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://horms.net/projects/kexec/kexec-tools;
    description = "Tools related to the kexec Linux feature";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
