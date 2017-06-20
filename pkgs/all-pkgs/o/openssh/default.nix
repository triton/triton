{ stdenv
, fetchurl

, audit_lib
, kerberos
, ldns
, libbsd
, libedit
, openssl_1-0-2
, pam
, zlib
}:

stdenv.mkDerivation rec {
  name = "openssh-7.5p1";

  src = fetchurl {
    url = "mirror://openbsd/OpenSSH/portable/${name}.tar.gz";
    hashOutput = false;
    sha256 = "9846e3c5fab9f0547400b4d2c017992f914222b3fd1f8eee6c7dc6bc5e59f9f0";
  };

  buildInputs = [
    audit_lib
    kerberos
    ldns
    libbsd
    libedit
    openssl_1-0-2
    pam
    zlib
  ];

  patches = [
    ./locale_archive.patch
  ];

  postPatch = ''
    # setuid can't be in a nixbuild
    grep -q 'INSTALL.*-m 4' Makefile.in
    sed -i '/INSTALL/s,-m 4,-m 0,' Makefile.in
  '';

  # I set --disable-strip because later we strip anyway. And it fails to strip
  # properly when cross building.
  configureFlags = [
    "--localstatedir=/var"
    "--with-pid-dir=/run"
    "--with-mantype=man"
    "--with-libedit=yes"
    "--disable-strip"
    "--with-ldns"
    "--with-libedit"
    "--with-audit=linux"
    "--with-ssl-dir=${openssl_1-0-2}"
    "--with-ssl-engine"
    "--with-pam"
    "--with-privsep-user=nobody"
    "--sysconfdir=/etc/ssh"
    "--with-kerberos5=${kerberos}"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc/ssh"
      "localstatedir=$TMPDIR"
      "PRIVSEP_PATH=$TMPDIR"
    )
  '';

  installTargets = [
    "install-nokeys"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "59C2 118E D206 D927 E667  EBE3 D3E5 F56B 6D92 0D30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.openssh.org/";
    description = "An implementation of the SSH protocol";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
