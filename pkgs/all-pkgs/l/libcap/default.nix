{ stdenv
, fetchurl
, lib
, perl
}:

let
  name = "libcap-2.34";

  tarballUrls = [
    "mirror://kernel/linux/libs/security/linux-privs/libcap2/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;
  
  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "aecdd42015955068d3d94b7caa9590fcb2de5df53ce53c61a21b912bfc0b1611";
  };
  
  nativeBuildInputs = [
    perl
  ];

  preConfigure = ''
    cd libcap
  '';

  makeFlags = [
    "lib=lib"
  ];

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sign") tarballUrls;
        pgpDecompress = true;
        pgpKeyFingerprint = "EAB3 3C96 9001 3C73 3916  AC83 9BA2 A5A6 30CB EA53";
      };
    };
  };

  meta = with lib; {
    description = "Library for working with POSIX capabilities";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
