{ stdenv
, fetchurl
, lib
, perl

, acl
, attr
, popt
, zlib
}:


stdenv.mkDerivation rec {
  name = "rsync-3.1.3";

  src = fetchurl {
    urls = [
      "mirror://samba/rsync/src/${name}.tar.gz"
      "mirror://samba/rsync/src-previews/${name}.tar.gz"
    ];
    hashOutput = false;
    sha256 = "55cc554efec5fdaad70de921cd5a5eeb6c29a95524c715f3bbf849235b0800c0";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    acl
    attr
    popt
    zlib
  ];

  configureFlags = [
    "--without-included-popt"
    "--without-included-zlib"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "0048 C8B0 26D4 C96F 0E58  9C2F 6C85 9FB1 4B96 A8C5";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    homepage = http://rsync.samba.org/;
    description = "A fast incremental file transfer utility";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
