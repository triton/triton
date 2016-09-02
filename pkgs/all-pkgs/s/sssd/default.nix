{ stdenv
, docbook_xml_dtd_44
, docbook-xsl
, fetchurl
, libxslt
, libxml2

, augeas
, c-ares
, cifs-utils
, cyrus-sasl
, dbus
, ding-libs
, dnsutils
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
, systemd_lib
, talloc
, tdb
, tevent
}:

let
  xmlcatalog = stdenv.mkDerivation {
    name = "sssd-xml-catalog";

    nativeBuildInputs = [
      libxml2
    ];

    preferLocalBuild = true;

    buildCommand = ''
      xmlcatalog --noout --create "$out"
      xmlcatalog --noout --add nextCatalog "$(find ${docbook-xsl} -name catalog.xml)" "" "$out"
      xmlcatalog --noout --add nextCatalog "$(find ${docbook_xml_dtd_44} -name catalog.xml)" "" "$out"
    '';
  };
in
stdenv.mkDerivation rec {
  name = "sssd-1.14.0";
  
  src = fetchurl {
    url = "https://fedorahosted.org/released/sssd/${name}.tar.gz";
    hashOutput = false;
    sha256 = "5c49ed0ecd17461a955bf031b73f257e8c40744d7485cd969976ccce819d624e";
  };

  nativeBuildInputs = [
    libxslt
    libxml2
  ];

  buildInputs = [
    augeas
    c-ares
    cifs-utils
    cyrus-sasl
    dbus
    ding-libs
    dnsutils
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
    systemd_lib
    talloc
    tdb
    tevent
  ];

  postPatch = ''
    sed -i 's,HAVE_SYSTEMD=no,HAVE_SYSTEMD=yes,g' configure
  '';

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
    "--with-nscd=/run/current-system/bin/nscd"
    "--with-ipa-getkeytab=/run/current-system/bin/ipa-getkeytab"
    "--without-python3-bindings"
    "--without-selinux"
    "--without-semanage"
  ];

  preBuild = ''
    cat Makefile
  '';

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
  parallelInstall = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "E4E3 6675 8CA0 716A AB80  4867 1EC6 AB75 32E7 BC25";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
