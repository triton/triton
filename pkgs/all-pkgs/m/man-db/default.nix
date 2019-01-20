{ stdenv
, fetchurl
, groff

, bzip2
, db
, gzip
, less
, libpipeline
, libseccomp
, lzip
, util-linux_full
, xz
, zlib
}:
 
stdenv.mkDerivation rec {
  name = "man-db-2.8.5";
  
  src = fetchurl {
    url = "mirror://savannah/man-db/${name}.tar.xz";
    hashOutput = false;
    sha256 = "b64d52747534f1fe873b2876eb7f01319985309d5d7da319d2bc52ba1e73f6c1";
  };

  nativeBuildInputs = [
    groff
  ];
  
  buildInputs = [
    db
    libpipeline
    libseccomp
    zlib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdtmpfilesdir=$out/lib/tmpfiles.d"
      "--with-systemdsystemunitdir=$out/lib/systemd/system"
    )
  '';

  configureFlags = [
    "--disable-setuid"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-pager=${less}/bin/less"
    "--with-nroff=${groff}/bin/nroff"
    "--with-eqn=${groff}/bin/eqn"
    "--with-neqn=${groff}/bin/neqn"
    "--with-tbl=${groff}/bin/tbl"
    "--with-col=${util-linux_full}/bin/col"
    "--with-refer=${groff}/bin/refer"
    "--with-pic=${groff}/bin/pic"
    "--with-gzip=${gzip}/bin/gzip"
    "--with-bzip2=${bzip2}/bin/bzip2"
    "--with-xz=${xz}/bin/xz"
    "--with-lzip=${lzip}/bin/lzip"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "AC0A 4FF1 2611 B6FC CF01  C111 3935 87D9 7D86 500B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://man-db.nongnu.org";
    description = "An implementation of the standard Unix documentation system accessed using the man command";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
