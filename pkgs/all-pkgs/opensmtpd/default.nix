{ stdenv
, bison
, fetchTritonPatch
, fetchurl

, db
, libasr
, libevent
, openssl
, pam
, zlib
}:

stdenv.mkDerivation rec {
  name = "opensmtpd-${version}";
  version = "5.9.2p1";

  src = fetchurl {
    url = "https://www.opensmtpd.org/archives/${name}.tar.gz";
    sha256 = "3522f273c1630c781facdb2b921228e338ed4e651909316735df775d6a70a71d";
  };

  nativeBuildInputs = [
    bison
  ];

  buildInputs = [
    db
    libasr
    libevent
    openssl
    pam
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "04a8e575c23f73ccefa548f7b9650db2491f39dc";
      file = "opensmtpd/libexec-env.patch";
      sha256 = "2ba90f17d419a0cef94c01a2ca2772828a280c791e7ca7a112c1446ad95833a0";
    })
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-mantype=doc"
    "--without-auth-bsdauth"
    "--with-auth-pam=smtpd"
    "--with-user-smtpd=smtpd"
    "--with-user-queue=smtpq"
    "--with-path-socket=/run"
    "--with-path-CAfile=/etc/ssl/certs/ca-certificates.crt"
    "--with-table-db"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
    )
  '';

  meta = with stdenv.lib; {
    homepage = https://www.opensmtpd.org/;
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
