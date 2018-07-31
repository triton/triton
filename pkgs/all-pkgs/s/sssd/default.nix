{ stdenv
, combine-xml-catalogs
, docbook_xml_dtd_44
, docbook-xsl
, fetchurl
, lib
, libxslt
, libxml2

, augeas
, bind_tools
, c-ares
, cifs-utils
, cyrus-sasl
, dbus
, ding-libs
, glib
, http-parser
, jansson
, keyutils
, krb5_lib
, ldb
, libnfsidmap
, libnl
, nss
, openldap
, pam
, pcre
, popt
, python2Packages
, samba_client
, systemd-dummy
, systemd_lib
, talloc
, tdb
, tevent
}:

let
  xmlcatalog = combine-xml-catalogs [
    docbook_xml_dtd_44
    docbook-xsl
  ];
in
stdenv.mkDerivation rec {
  name = "sssd-1.16.2";

  src = fetchurl {
    url = "https://releases.pagure.org/SSSD/sssd/${name}.tar.gz";
    multihash = "QmZpsxm4T5WC41MTydechEb7L51RpFoqMcQJrHoPpqtYiE";
    hashOutput = false;
    sha256 = "fe5b1fcc5b4359631f7edf25f8940f3155de68e2f4ac7bfeb634687ccabc570c";
  };

  nativeBuildInputs = [
    libxslt
    libxml2
  ];

  buildInputs = [
    augeas
    bind_tools
    c-ares
    cifs-utils
    cyrus-sasl
    dbus
    ding-libs
    glib
    http-parser
    jansson
    keyutils
    krb5_lib
    ldb
    libnfsidmap
    libnl
    nss
    openldap
    pam
    pcre
    popt
    python2Packages.python
    python2Packages.python-ldap
    samba_client
    systemd-dummy
    systemd_lib
    talloc
    tdb
    tevent
  ];

  # Configure doesn't correctly export this value
  SGML_CATALOG_FILES = xmlcatalog;

  preConfigure = ''
    configureFlagsArray+=(
      "--with-ldb-lib-dir=$out/lib/ldb"
      "--with-systemdunitdir=$out/lib/systemd/system"
      "--with-systemdconfdir=$out/etc/systemd/system"
      "--with-xml-catalog-path=${xmlcatalog}"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-initscript=systemd"
    "--with-nscd=/run/current-system/sw/bin/nscd"
    "--with-ipa-getkeytab=/run/current-system/sw/bin/ipa-getkeytab"
    "--with-session-recording-shell=/run/current-system/sw/bin/tlog-rec-session"
    "--without-python3-bindings"
    "--without-selinux"
    "--without-semanage"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "initdir=$TMPDIR"
      "localstatedir=$TMPDIR"
      "dbpath=$TMPDIR"
      "gpocachepath=$TMPDIR"
      "logpath=$TMPDIR"
      "mcpath=$TMPDIR"
      "pidpath=$TMPDIR"
      "pipepath=$TMPDIR"
      "pubconfpath=$TMPDIR"
      "runstatedir=$TMPDIR"
      "secdbpath=$TMPDIR"
    )
  '';

  # There be dragons here
  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "E4E3 6675 8CA0 716A AB80  4867 1EC6 AB75 32E7 BC25";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "System Security Services Daemon";
    homepage = https://pagure.io/SSSD/sssd/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
