{ stdenv
, fetchurl
, lib
, perl
}:

let
  name = "libcap-2.26";

  tarballUrls = [
    "mirror://kernel/linux/libs/security/linux-privs/libcap2/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "libcap-2.26";
  
  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "b630b7c484271b3ba867680d6a14b10a86cfa67247a14631b14c06731d5a458b";
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
    makeFlagsArray+=("prefix=$dev")
  '';

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

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
