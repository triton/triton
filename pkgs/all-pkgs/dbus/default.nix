{ stdenv
, fetchurl

, audit_lib
, expat
, libcap-ng
, systemd_lib
, xorg
}:

stdenv.mkDerivation rec {
  name = "dbus-1.10.8";
  
  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    sha256 = "0560y3hxpgh346w6avcrcz79c8ansmn771y5xpcvvlr6m8mx5wxs";
  };

  buildInputs = [
    audit_lib
    expat
    libcap-ng
    systemd_lib
    xorg.libX11
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
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
    "--enable-libaudit"
    "--enable-systemd"
    "--disable-selinux"
    "--disable-apparmor"
    "--disable-tests"
    "--enable-x11-autolaunch"
    "--enable-user-session"
  ];

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
