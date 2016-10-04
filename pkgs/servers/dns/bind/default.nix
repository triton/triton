{ stdenv
, fetchurl
, libtool
, dhcp
, docbook-xsl-ns

, db
, idnkit
, json-c
, kerberos
, libcap
, libseccomp
, libxml2
, mysql_lib
, ncurses
, openldap
, openssl
, postgresql
, python
, readline

, suffix ? ""
}:

let
  toolsOnly = suffix == "tools";

  inherit (stdenv.lib)
    optionals
    optionalString;

  version = "9.10.4-P3";
in
stdenv.mkDerivation rec {
  name = "bind${optionalString (suffix != "") "-${suffix}"}-${version}";

  src = fetchurl {
    url = "http://ftp.isc.org/isc/bind9/${version}/bind-${version}.tar.gz";
    hashOutput = false;
    sha256 = "a075e5ce89fddccb0e64d1777d59161387dd5151cf4e7d1a93875a487812baef";
  };

  nativeBuildInputs = [
    docbook-xsl-ns
    libtool
  ];

  buildInputs = [
    idnkit
    json-c
    kerberos
    libcap
    libseccomp
    libxml2
    ncurses
    openssl
    python
    readline
  ] ++ optionals (!toolsOnly) [
    db
    openldap
    mysql_lib
    postgresql
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--enable-seccomp"
    "--with-python=${python.interpreter}"
    "--enable-kqueue"
    "--enable-epoll"
    "--enable-devpoll"
    "--without-geoip"  # TODO(wkennington): GeoDNS support
    "--with-gssapi=${kerberos}"
    "--with-libtool"
    "--disable-native-pkcs11"
    "--with-openssl=${openssl}"
    "--with-pkcs11"
    "--with-ecdsa"
    "--without-gost"  # Insecure cipher
    "--with-aes"
    "--enable-openssl-hash"
    "--enable-sit"
    "--with-sit-alg=aes"
    "--with-libxml2=${libxml2}"
    "--with-libjson=${json-c}"
    "--enable-largefile"
    "--without-purify"
    "--without-gperftools-profiler"
    "--disable-backtrace"
    "--disable-symtable"
    "--enable-ipv6"
    "--without-kame"
    "--with-readline"
    "--disable-isc-spnego"
    "--enable-chroot"
    "--enable-linux-caps"
    "--enable-atomic"
    "--disable-fixed-rrset"
    "--enable-rpz-nsip"
    "--enable-rpz-nsdname"
    "--enable-filter-aaaa"
    "--with-docbook-xsl=${docbook-xsl-ns}/share/xsl/docbook"
    "--with-idn=${idnkit}"
    "--without-atf"
    "--with-tuning=large"
    "--enable-querytrace"
    "--with-dlopen"
    "--without-make-clean"
    "--enable-full-report"
  ] ++ optionals (!toolsOnly) [
    "--with-dlz-postgres=${postgresql}"
    "--with-dlz-mysql=${mysql_lib}"
    "--with-dlz-bdb=${db}"
    "--with-dlz-filesystem"
    "--with-dlz-ldap=${openldap}"
    "--without-dlz-odbc"
    "--with-dlz-stub"
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
  ] ++ optionals toolsOnly [
    "DESTDIR=\${TMPDIR}"
  ];

  postInstall = optionalString toolsOnly ''
    mkdir -p $out/{bin,etc,lib,share/man/man1}
    install -m 0755 $TMPDIR/$out/bin/{dig,host,nslookup,nsupdate} $out/bin
    install -m 0644 $TMPDIR/$out/etc/bind.keys $out/etc
    install -m 0644 $TMPDIR/$out/lib/*.so.* $out/lib
    install -m 0644 $TMPDIR/$out/share/man/man1/{dig,host,nslookup,nsupdate}.1 $out/share/man/man1
  '';

  parallelInstall = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sha512.asc") src.urls;
      pgpKeyFile = dhcp.srcVerification.pgpKeyFile;
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.isc.org/software/bind";
    description = "Domain name server";
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
