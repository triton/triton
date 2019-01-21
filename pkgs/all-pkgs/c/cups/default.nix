{ stdenv
, fetchurl

, acl
, avahi
, dbus
, gnutls
#, kerberos
, libgcrypt
, libpaper
, libusb
, pam
, python2
#, openjdk
, systemd_lib
, xdg-utils
#, xinetd
, zlib
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt;

  version = "2.2.10";
in
stdenv.mkDerivation rec {
  name = "cups-${version}";

  src = fetchurl {
    url = "https://github.com/apple/cups/releases/download/v${version}/"
      + "cups-${version}-source.tar.gz";
    hashOutput = false;
    sha256 = "77c8b2b3bb7fe8b5fbfffc307f2c817b2d7ec67b657f261a1dd1c61ab81205bb";
  };

  buildInputs = [
    acl
    avahi
    dbus
    gnutls
    #kerberos
    libgcrypt
    libpaper
    libusb
    pam
    python2
    #openjdk
    systemd_lib
    xdg-utils
    #xinetd
    zlib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemd=$out/lib/systemd/system"
      "--with-dbusdir=$out/etc/dbus-1"
      "--with-docdir=$out/share/cups/html"
      "--with-xinetd=$out/etc/xinetd.d"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-mallinfo"
    "--${boolEn (libpaper != null)}-libpaper"
    "--${boolEn (libusb != null)}-libusb"
    #--enable-tcp-wrappers
    "--${boolEn (acl != null)}-acl"
    "--${boolEn (dbus != null)}-dbus"
    "--enable-shared"
    "--disable-libtool-unsupported"
    "--disable-debug"
    "--disable-debug-guards"
    "--disable-debug-printfs"
    "--disable-unit-tests"
    #"--enable-relro"
    # FIXME: kerberos support causes chromium to fail to build
    #"--${boolEn (kerberos != null)}-gssapi"
    "--enable-threads"
    "--${boolEn (
      gnutls != null
      && libgcrypt != null)}-ssl"
    #"--enable-cdsassl"
    "--${boolEn (pam != null)}-pam"
    "--${boolEn (
      gnutls != null
      && libgcrypt != null)}-gnutls"
    "--${boolEn (avahi != null)}-avahi"
    "--disable-dnssd"
    "--disable-launchd"
    "--${boolEn (systemd_lib != null)}-systemd"
    #"--disable-upstart"
    #"--enable-page-logging"
    #"--enable-browsing"
    #"--enable-default-shared"
    "--enable-raw-printing"
    #"--enable-webif"
    # "--with-dbusdir=$out/etc/dbus-1"
    "--with-components=all"
    # --with-cachedir
    # --with-icondir
    # --with-menudir
    # --with-fontpath
    # --with-logdir
    # --with-rundir=/run/cups
    # XXX: flag is not a proper boolean, build fails with optim enabled
    #"--without-optim"
    "--${boolWt (systemd_lib != null)}-systemd"
    "--with-languages=all"
    # --with-cups-user=lp
    # --with-cups-group=lp
    # --with-system-groups=lpadmin
    # FIXME: add java support
    "--without-java"
    "--without-perl"
    "--without-php"
    "--${boolWt (python2 != null)}-python"
  ];

  preInstall = ''
    installFlagsArray+=(
      # Don't try to write in /var at build time.
      "CACHEDIR=$TMPDIR"
      "LOGDIR=$TMPDIR"
      "REQUESTS=$TMPDIR"
      "STATEDIR=$TMPDIR"

      # Idem for /etc.
      "PAMDIR=$out/etc/pam.d"
      "DBUSDIR=$out/etc/dbus-1"
      "XINETD=$out/etc/xinetd.d"
      "SERVERROOT=$out/etc/cups"

      # Idem for /usr.
      "MENUDIR=$out/share/applications"
      "ICONDIR=$out/share/icons"
    )
  '';

  installFlags = [
    # Work around a Makefile bug.
    # FIXME: figure out what the issue was and if it is still valid
    "CUPS_PRIMARY_SYSTEM_GROUP=root"
  ];

  postInstall = ''
    # Delete obsolete stuff that conflicts with cups-filters.
    rm -rf $out/share/cups/banners $out/share/cups/data/testprint

    # Rename systemd files provided by CUPS
    for f in $out/lib/systemd/system/*; do
      sed -i "$f" \
        -e 's/org.cups.cupsd/cups/g' \
        -e 's/org.cups.//g'

      if [[ "$f" =~ .*cupsd\..* ]] ; then
        mv "$f" "''${f/org\.cups\.cupsd/cups}"
      else
        mv "$f" "''${f/org\.cups\./}"
      fi
    done

    # Use xdg-open
    sed -i $out/share/applications/cups.desktop \
      -e 's/Exec=htmlview/Exec=xdg-open/g'
  '';

  passthru = {
    inherit version;

    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "45D0 8394 6E30 3528 2B3C  CA9A F434 1042 35DA 97EB";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = https://cups.org/;
    description = "A standards-based printing system for UNIX";
    license = with licenses; [
      gpl2
      lgpl2
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
