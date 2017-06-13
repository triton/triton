{ stdenv
, fetchurl
, pkgconfig

, hiredis
, libasr
, libevent
, luajit
, mariadb-connector-c
, openssl
, pam
, perl
, postgresql
, python2
, sqlite
}:

stdenv.mkDerivation rec {
  name = "opensmtpd-extras-${version}";
  version = "5.7.1";

  src = fetchurl {
    url = "https://www.opensmtpd.org/archives/${name}.tar.gz";
    sha256 = "1kld4hxgz792s0cb2gl7m2n618ikzqkj88w5dhaxdrxg4x2c4vdm";
  };

  buildInputs = [
    hiredis
    libasr
    libevent
    luajit
    mariadb-connector-c
    openssl
    pam
    perl
    postgresql
    python2
    sqlite
  ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${hiredis}/include/hiredis"
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-privsep-user=smtpd"
    "--with-filter-clamav"
    "--with-filter-dkim-signer"
    "--with-filter-dnsbl"
    "--with-filter-lua"
    "--with-filter-monkey"
    "--with-filter-pause"
    "--with-filter-perl"
    "--with-filter-python"
    "--with-filter-regex"
    "--with-filter-spamassassin"
    "--with-filter-stub"
    "--with-filter-trace"
    "--with-filter-void"
    "--with-queue-null"
    "--with-queue-python"
    "--with-queue-ram"
    "--with-queue-stub"
    "--with-table-ldap"
    "--with-table-mysql"
    "--with-table-postgres"
    "--with-table-redis"
    "--with-table-socketmap"
    "--with-table-passwd"
    "--with-table-python"
    "--with-table-sqlite"
    "--with-table-stub"
    "--with-scheduler-ram"
    "--with-scheduler-stub"
    "--with-scheduler-python"

    "--with-lua=${luajit}"
    "--with-lua-type=luajit"
    "--with-python=${python2}"
  ];

  meta = with stdenv.lib; {
    homepage = https://www.opensmtpd.org/;
    description = "Extra plugins for the OpenSMTPD mail server";
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
