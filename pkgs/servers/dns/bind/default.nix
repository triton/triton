{ stdenv
, fetchurl
, libtool
, docbook5_xsl

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
, postgresql_lib
, python
, readline

, suffix ? ""
}:

let
  toolsOnly = suffix == "tools";

  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "bind${optionalString (suffix != "") "-${suffix}"}-${version}";
  version = "9.10.3-P3";

  src = fetchurl {
    url = "http://ftp.isc.org/isc/bind9/${version}/bind-${version}.tar.gz";
    sha256 = "10yblk8qbb85qxakzdjy5qmqvqj4rlcqsqvlkriglampzg8i0239";
  };

  nativeBuildInputs = [
    docbook5_xsl
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
    postgresql_lib
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
    "--with-docbook-xsl=${docbook5_xsl}/share/xsl/docbook"
    "--with-idn=${idnkit}"
    "--without-atf"
    "--with-tuning=large"
    "--enable-querytrace"
    "--with-dlopen"
    "--without-make-clean"
    "--enable-full-report"
  ] ++ optionals (!toolsOnly) [
    "--with-dlz-postgres=${postgresql_lib}"
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
