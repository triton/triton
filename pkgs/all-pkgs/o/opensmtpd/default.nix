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

let
  version = "6.0.1p1";

  name = "opensmtpd-${version}";

  baseUrls = [
    "https://www.opensmtpd.org/archives/${name}"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    url = map (n: "${n}.tar.gz") baseUrls;
    hashOutput = false;
    sha256 = "4cd61cd2d668715570896338c81d71eb64e6f90b3f88c5639b378db7b1af864a";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      signifyUrls = map (n: "${n}.sum.sig") baseUrls;
      signifyPub = "RWSoKNlSRN/G8zpyHzdK1MVuLrQi3J1Yfo9XsjgFHnCvabkcb6bBRBf0";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
