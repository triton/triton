{ stdenv
, fetchurl

, acl
, attr
, libburn
, libisofs
, readline
, zlib
}:

stdenv.mkDerivation rec {
  name = "libisoburn-1.4.4";

  src = fetchurl {
    url = "http://files.libburnia-project.org/releases/${name}.tar.gz";
    allowHashOutput = false;
    multihash = "QmfKeuBkXucrqpoR8gu6Djc31S66Z92BrUBnLoCZD1BaSG";
    sha256 = "7b02a1930382d7ebb4ed9e32917aebd4967c2255fdb3549a95ace5c6276fc2d6";
  };

  buildInputs = [
    acl
    attr
    libburn
    libisofs
    readline
    zlib
  ];

  configureFlags = [
    "--enable-libreadline"
    "--disable-libedit"
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
