{ stdenv
, fetchTritonPatch
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
  name = "openssh-7.7p1";

  src = fetchurl {
    url = "mirror://openbsd/OpenSSH/portable/${name}.tar.gz";
    hashOutput = false;
    sha256 = "d73be7e684e99efcd024be15a30bffcbe41b012b2f7b3c9084aed621775e6b8f";
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
    (fetchTritonPatch {
      rev = "0adef9010d48cf06dd295edc65d6ffc1c618ba10";
      file = "o/openssh/0001-Pass-LOCALE_ARCHIVE-to-children.patch";
      sha256 = "0dd79faa9cb039c4c34aea5a8307dc0a55464a839ddd7e5f9c5ec5a0c2baec5c";
    })
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
