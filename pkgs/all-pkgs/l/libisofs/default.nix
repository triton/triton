{ stdenv
, fetchurl

, acl
, attr
, zlib
}:

stdenv.mkDerivation rec {
  name = "libisofs-1.4.4";

  src = fetchurl {
    url = "http://files.libburnia-project.org/releases/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmcCGco1R8bEKVqZYUBnF2LngiEh2AYjyornmz5bDRC1FM";
    sha256 = "2418f0feeea652dc122a39840d58c6931aa1008480385f7403881d82a629bdfd";
  };

  buildInputs = [
    acl
    attr
    zlib
  ];

  configureFlags = [
    "--enable-libacl"
    "--enable-xattr"
    "--enable-zlib"
    "--disable-libjte"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "44BC 9FD0 D688 EB00 7C4D  D029 E9CB DFC0 ABC0 A854";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
