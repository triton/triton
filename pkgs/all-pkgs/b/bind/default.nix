{ stdenv
, fetchurl
, lib
, libtool
, dhcp
, docbook-xsl-ns

, db
, fstrm
, json-c
, kerberos
, libcap
, libxml2
, lmdb
, mariadb-connector-c
, ncurses
, openldap
, openssl
, postgresql
, protobuf-c
, python3Packages
, readline
, zlib

, suffix ? ""
}:

let
  toolsOnly = suffix == "tools";

  inherit (lib)
    optionals
    optionalString;

  version = "9.14.4";
in
stdenv.mkDerivation rec {
  name = "bind${optionalString (suffix != "") "-${suffix}"}-${version}";

  src = fetchurl {
    url = "https://ftp.isc.org/isc/bind9/${version}/bind-${version}.tar.gz";
    multihash = "QmTqVQub44TAnYNJcjsX1XCUkLNvXMH6Na81qKU9r9EU8F";
    hashOutput = false;
    sha256 = "312efb82a6889074f31ef2849af498b3ec97ca69acd5c4e5e4b4045a8fe6b83f";
  };

  nativeBuildInputs = [
    docbook-xsl-ns
    libtool
  ] ++ optionals (!toolsOnly) [
    protobuf-c
  ];

  buildInputs = [
    kerberos
    ncurses
    openssl
    readline
  ] ++ optionals (!toolsOnly) [
    db
    fstrm
    json-c
    libcap
    libxml2
    lmdb
    mariadb-connector-c
    openldap
    postgresql
    protobuf-c
    python3Packages.python
    python3Packages.ply
    zlib
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--enable-largefile"
    "--disable-backtrace"
    "--disable-symtable"
    "--enable-full-report"
    "--with-openssl=${openssl}"
    "--with-gssapi=${kerberos}/bin/krb5-config"
  ] ++ optionals (toolsOnly) [
    "--disable-linux-caps"
    "--without-python"
  ] ++ optionals (!toolsOnly) [
    "--enable-dnstap"
    "--enable-dnsrps-dl"
    "--enable-dnsrps"
    "--with-lmdb=${lmdb}"
    "--with-libjson=${json-c}"
    "--with-zlib=${zlib}"
    "--with-dlz-postgres=${postgresql}"
    "--with-dlz-mysql=${mariadb-connector-c}"
    "--with-dlz-bdb=${db}"
    "--with-dlz-filesystem"
    "--with-dlz-ldap=${openldap}"
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "localstatedir=\${TMPDIR}"
  ] ++ optionals toolsOnly [
    "DESTDIR=\${TMPDIR}"
  ];

  postInstall = optionalString toolsOnly ''
    mkdir -p $out/{bin,etc,share/man/man1}
    install -m 0755 $TMPDIR/$out/bin/{dig,host,nslookup,nsupdate} $out/bin
    install -m 0644 $TMPDIR/$out/etc/bind.keys $out/etc
    install -m 0644 $TMPDIR/$out/share/man/man1/{dig,host,nslookup,nsupdate}.1 $out/share/man/man1
  '';

  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHashAlgo
        outputHash;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sha512.asc") src.urls;
        pgpKeyFile = dhcp.srcVerification.pgpKeyFile;
        pgpKeyFingerprints = [
          "AE3F AC79 6711 EC59 FC00  7AA4 74BB 6B9A 4CBB 3D38"
        ];
      };
    };
  };

  meta = with lib; {
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
