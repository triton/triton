{ stdenv
, fetchurl

, acl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libisofs-1.4.8";

  src = fetchurl {
    url = "http://files.libburnia-project.org/releases/${name}.tar.gz";
    multihash = "QmaYUk6YDiiL7gKNLBuJpyb7Y9QBHtkVtB3uHDYGcYr7qi";
    hashOutput = false;
    sha256 = "dc9de9df366c27cf03d31d860c83a08ddad9028fe192801ee344602ccec29b69";
  };

  buildInputs = [
    acl
    zlib
  ];

  postPatch = ''
    sed -i 's,attr/xattr.h,sys/xattr.h,' \
      configure libisofs/aaip-os-linux.c
  '';

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
