{ stdenv
, fetchurl

, expat
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dbus-1.10.6";
  
  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    sha256 = "0pykylm78hf6pgj85gpqygv2rh7bksadnwnqck6pdpbylw4gmzmm";
  };

  buildInputs = [
    expat
    systemd_lib
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
    "--enable-libaudit"
    "--enable-systemd"
    "--disable-selinux"
    "--disable-apparmor"
    "--disable-tests"
    "--disable-x11-autolaunch"
    "--with-session-socket-dir=/tmp"
  ];

  meta = with stdenv.lib; {
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
