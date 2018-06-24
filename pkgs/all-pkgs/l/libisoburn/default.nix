{ stdenv
, fetchurl

, acl
, libburn
, libisofs
, readline
, zlib
}:

stdenv.mkDerivation rec {
  name = "libisoburn-1.4.8";

  src = fetchurl {
    url = "http://files.libburnia-project.org/releases/${name}.tar.gz";
    multihash = "Qmcw3rrfR8UysFDLJgjE13nvsJdk3vKRHtzz3ZtcrMbYQQ";
    hashOutput = false;
    sha256 = "91cf50473f0f19400629515974bda441545aaae29862dcbbdb28d87b821ca5a5";
  };

  postPatch = ''
    sed -i 's,attr/xattr.h,sys/xattr.h,' \
      configure
  '';

  buildInputs = [
    acl
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
