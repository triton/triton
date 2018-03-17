{ stdenv
, docbook_xml_dtd_42
, docbook_xml_dtd_45
, docbook-xsl
, fetchurl
, gettext
, libxslt
, perl
, pythonPackages

, avahi
, acl
, ceph
, cups
, dbus
, glusterfs
, gnutls
, iniparser
, krb5_full
, ldb
, libaio
, libarchive
, libbsd
, libcap
, libgcrypt
, libgpg-error
, libunwind
, ncurses
, nss_wrapper
, openldap
, pam
, popt
, rdma-core
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

, type ? ""
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  version = "4.8.0";
  name = "samba${if isClient then "-client" else ""}-${version}";

  tarballUrls = [
    "mirror://samba/samba/stable/samba-${version}.tar"
  ];

  isClient = type == "client";
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "87d9b585dbd8628e79aabb6e621a94bd20a072a00762e78e0899fad22fc18fb7";
  };

  nativeBuildInputs = [
    pythonPackages.python
    perl
    libxslt
    docbook-xsl
    docbook_xml_dtd_42
    docbook_xml_dtd_45
    pythonPackages.wrapPython
    gettext
  ];

  buildInputs = [
    acl
    avahi
    cups
    gnutls
    iniparser
    krb5_full
    ldb
    libarchive
    libbsd
    libcap
    libgcrypt
    libgpg-error
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
  ] ++ optionals (!isClient) [
    ceph
    dbus
    glusterfs
    libaio
    pythonPackages.etcd
    rdma-core
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
    (if isClient then null else "--with-libcephfs=${ceph}")
    (if isClient then null else "--enable-glusterfs")

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
    "--with-system-mitkrb5" "${krb5_full}"
    "--with-system-mitkdc" "${krb5_full}/bin/krb5kdc"
    # "--without-ad-dc"

    # ctdb/wscript
    (if isClient then null else "--enable-infiniband")
    #(if isClient then null else "--enable-pmda")
    (if isClient then null else "--enable-etcd-reclock")
    (if isClient then null else "--enable-ceph-reclock")
  ];

  configurePhase = ''
    patchShebangs buildtools/bin/waf
    export PATH="$(pwd)/buildtools/bin:$PATH"
    configureFlagsArray+=("--prefix=$out")
    waf configure -j $NIX_BUILD_CORES $configureFlags "''${configureFlagsArray[@]}"
  '';

  buildPhase = ''
    waf build -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    waf install -j $NIX_BUILD_CORES --destdir "$out"

    dir="$out/$out"
    mv "$out/$out"/* "$out"
    while [ "$out" != "$dir" ]; do
      rmdir "$dir"
      dir="$(dirname "$dir")"
    done

    # Remove unecessary components
    rm -r "$out"/var
    rm -r "$out"/libexec/ctdb/tests
    rm -r "$out"/lib/python2.7/site-packages/samba/tests
    rm "$out"/bin/ctdb_run{_cluster,}_tests
    rm -r "$out"/share/ctdb/tests
    rmdir "$out"/share/ctdb
  '';

  preFixup = optionalString isClient ''
    smbclient_bins=(
      "$out/bin/smbclient"
      "$out/bin/rpcclient"
      "$out/bin/smbspool"
      "$out/bin/smbtree"
      "$out/bin/smbcacls"
      "$out/bin/smbcquotas"
      "$out/bin/smbget"
      "$out/bin/net"
      "$out/bin/nmblookup"
      "$out/bin/smbtar"
    )
    for lib in $(find $out/lib $out/lib/security -maxdepth 1 -not -type d); do
      smbclient_bins+=("$lib")
    done

    smbclient_pcs=($(find "$out/lib/pkgconfig" -maxdepth 1 -not -type d))
    for smbclient_pc in "''${smbclient_pcs[@]}"; do
      names=$(sed 's, -l,\n\0,g' $smbclient_pc | sed -n 's,.* -l\([^ ]*\).*,\1,p')
      for name in $names; do
        smbclient_bins+=($(find $out/lib -name lib''${name}.so\*))
      done
    done

    for smbclient_bin in "''${smbclient_bins[@]}"; do
      smbclient_bins+=($(ldd $smbclient_bin | awk '{ print $3 }' | grep $out || true))
    done

    declare -A smbclient_files
    for i in "''${smbclient_bins[@]}" "''${smbclient_pcs[@]}" $(find $out/include $out/lib/python* -not -type d); do
      local current="$i"
      local link
      while link="$(readlink "$current")" && [ -n "$link" ]; do
        smbclient_files["$current"]=1
        current="$(realpath -s "$(dirname "$current")/$link")"
      done
      smbclient_files["$current"]=1
    done

    for i in $(find $out -not -type d); do
      if [ "''${smbclient_files[$i]}" != "1" ]; then
        rm $i
      fi
    done
    for dir in $(find $out -type d | sort -r); do
      rmdir "$dir" || true
    done
  '' + ''
    # Correct python program paths
    wrapPythonPrograms $out/bin
  '';

  # FIXME
  buildDirCheck = false;

  passthru = rec {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") tarballUrls;
      pgpDecompress = true;
      inherit (pgp.samba) pgpKeyFingerprint;
      inherit (src) urls outputHash outputHashAlgo;
    };

    pgp = {
      samba = {
        pgpKeyFingerprint = "52FB C0B8 6D95 4B08 4332  4CDC 6F33 915B 6568 B7EA";
      };
      library = {
        pgpKeyFingerprint = "9147 A339 7195 18EE 9011  BCB5 4793 9161 1308 4025";
      };
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
