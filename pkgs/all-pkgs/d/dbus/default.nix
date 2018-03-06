{ stdenv
, docbook_xml_dtd_44
, docbook-xsl
, fetchurl
, libxslt
, xmlto

, audit_lib
, expat
, libcap-ng
, libx11
, systemd_lib
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "dbus-1.12.6";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    multihash = "QmXyxGgJ1qM69o7kutpiCoHFdp6gVEZRFNnSxjkweDWJYt";
    hashOutput = false;
    sha256 = "621b902a07badec16c9e43eda43903cd0e1e69e11b13143da71c1889b062f116";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_44
    docbook-xsl
    libxslt
    xmlto
  ];

  buildInputs = [
    audit_lib
    expat
    libcap-ng
    libx11
    systemd_lib
    xorgproto
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
      "--with-systemduserunitdir=$out/etc/systemd/user"
    )
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR/var"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-session-socket-dir=/tmp"
    "--enable-xml-docs"
    "--enable-libaudit"
    "--enable-inotify"
    "--enable-systemd"
    "--disable-selinux"
    "--disable-apparmor"
    "--enable-systemd"
    "--disable-tests"
    "--enable-epoll"
    "--enable-x11-autolaunch"
    "--enable-user-session"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Simon McVittie
        "DA98 F25C 0871 C49A 59EA  FF2C 4DE8 FF2A 63C7 CC90"
        "3C86 72A0 F496 37FE 064A  C30F 52A4 3A1E 4B77 B059"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A message bus system for interprocess communication (IPC)";
    homepage = http://dbus.freedesktop.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
