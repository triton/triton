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
  name = "rsync-3.1.3pre1";

  src = fetchurl {
    url = "mirror://samba/rsync/src-previews/${name}.tar.gz";
    hashOutput = false;
    sha256 = "6337962632006f9e8664d759cd2bbe5958e4e20a12a72a05c9dbcad0b955faf5";
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
