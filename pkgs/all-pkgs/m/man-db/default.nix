{ stdenv
, fetchurl
, groff

, db
, libpipeline
}:
 
stdenv.mkDerivation rec {
  name = "man-db-2.7.6.1";
  
  src = fetchurl {
    url = "mirror://savannah/man-db/${name}.tar.xz";
    hashOutput = false;
    sha256 = "08edbc52f24aca3eebac429b5444efd48b9b90b9b84ca0ed5507e5c13ed10f3f";
  };

  nativeBuildInputs = [
    groff
  ];
  
  buildInputs = [
    db
    libpipeline
  ];

  configureFlags = [
    "--disable-setuid"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-systemdtmpfilesdir=\${out}/lib/tmpfiles.d"
    "--with-eqn=${groff}/bin/eqn"
    "--with-neqn=${groff}/bin/neqn"
    "--with-nroff=${groff}/bin/nroff"
    "--with-pic=${groff}/bin/pic"
    "--with-refer=${groff}/bin/refer"
    "--with-tbl=${groff}/bin/tbl"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
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
