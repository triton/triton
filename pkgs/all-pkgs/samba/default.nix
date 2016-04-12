{ stdenv
, docbook_xml_dtd_42
, docbook_xml_dtd_45
, docbook_xsl
, fetchurl
, gettext
, libxslt
, perl
, pythonPackages

, avahi
, acl
, ceph_lib
, cups
, dbus
, glusterfs
, gnutls
, iniparser
, kerberos
, ldb
, libaio
, libarchive
, libbsd
, libcap
, libgcrypt
, libgpg-error
, libibverbs
, librdmacm
, libunwind
, ncurses
, nss_wrapper
, openldap
, pam
, popt
, readline
, resolv_wrapper
, socket_wrapper
, subunit
, systemd_lib
, talloc
, tdb
, tevent
, uid_wrapper
, zlib
}:

let
  name = "samba-4.4.2";

  tarballUrls = [
    "mirror://samba/samba/stable/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    allowHashOutput = false;
    sha256 = "eaecd41a85ebb9507b8db9856ada2a949376e9d53cf75664b5493658f6e5926a";
  };

  nativeBuildInputs = [
    pythonPackages.python
    perl
    libxslt
    docbook_xsl
    docbook_xml_dtd_42
    docbook_xml_dtd_45
    pythonPackages.wrapPython
    gettext
  ];

  buildInputs = [
    acl
    avahi
    ceph_lib
    cups
    dbus
    glusterfs
    gnutls
    iniparser
    kerberos
    ldb
    libaio
    libarchive
    libbsd
    libcap
    libgcrypt
    libgpg-error
    libibverbs
    librdmacm
    libunwind
    ncurses
    nss_wrapper
    openldap
    pam
    popt
    readline
    resolv_wrapper
    socket_wrapper
    subunit
    systemd_lib
    talloc
    tdb
    tevent
    uid_wrapper
    zlib
  ];

  pythonPath = [
    talloc
    ldb
    tdb
  ];

  postPatch = ''
    # Removes absolute paths in scripts
    sed -i 's,/sbin/,,g' ctdb/config/functions

    # Fix the XML Catalog Paths
    sed -i "s,\(XML_CATALOG_FILES=\"\),\1$XML_CATALOG_FILES ,g" buildtools/wafsamba/wafsamba.py
  '';

  configureFlags = [
    # source3/wscript options
    "--with-static-modules=NONE"
    "--with-shared-modules=ALL"
    "--with-winbind"
    "--with-ads"
    "--with-ldap"
    "--enable-cups"
    "--enable-iprint"
    "--with-pam"
    "--with-quotas"
    "--with-sendfile-support"
    "--with-utmp"
    "--with-utmp"
    "--enable-pthreadpool"
    "--enable-avahi"
    "--with-iconv"
    "--with-acl-support"
    "--with-dnsupdate"
    "--with-syslog"
    "--with-automount"
    "--without-fam"
    "--with-libarchive"
    "--with-cluster-support"
    "--with-regedit"
    "--with-libcephfs=${ceph_lib}"
    "--enable-glusterfs"

    # dynconfig/wscript options
    "--enable-fhs"
    "--sysconfdir=/etc"
    "--localstatedir=/var"

    # buildtools/wafsamba/wscript options
    "--bundled-libraries=com_err"
    "--private-libraries=NONE"
    "--builtin-libraries=replace"
    "--abi-check"
    "--why-needed"
    "--with-libiconv"

    # lib/util/wscript
    "--with-systemd"

    # source4/lib/tls/wscript options
    "--enable-gnutls"

    # wscript options
    "--with-system-mitkrb5"
    # "--without-ad-dc"

    # ctdb/wscript
    "--enable-infiniband"
    "--enable-pmda"
  ];

  preInstall = ''
    sed \
      -e "s,'/etc,'$out/etc,g" \
      -e "s,'/var,'$TMPDIR/var,g" \
      -i bin/c4che/default.cache.py
  '';

  postInstall = ''
    # Remove unecessary components
    rm -r $out/{lib,share}/ctdb-tests
    rm $out/bin/ctdb_run{_cluster,}_tests
  '';

  preFixup = ''
    # Correct python program paths
    wrapPythonPrograms
  '';

  # We need to make sure rpaths are correct for all of our libraries
  postFixup = ''
    SAMBA_LIBS="$(find $out -type f -name \*.so -exec dirname {} \; | sort | uniq)"
    find $out -type f | while read BIN; do
      OLD_LIBS="$(patchelf --print-rpath "$BIN" 2>/dev/null | tr ':' '\n')" || continue
      ALL_LIBS="$(echo -e "$SAMBA_LIBS\n$OLD_LIBS" | sort | uniq | tr '\n' ':')"
      patchelf --set-rpath "$ALL_LIBS" "$BIN" 2>/dev/null
      patchelf --shrink-rpath "$BIN"
    done
  '';

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") tarballUrls;
      pgpKeyId = "6568B7EA";
      pgpKeyFingerprint = "52FB C0B8 6D95 4B08 4332  4CDC 6F33 915B 6568 B7EA";
      pgpDecompress = true;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.samba.org/;
    description = "The standard Windows interoperability suite of programs for Linux and Unix";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
