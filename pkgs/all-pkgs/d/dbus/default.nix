{ stdenv
, fetchurl

, audit_lib
, expat
, libcap-ng
, systemd_lib
, xorg
}:

stdenv.mkDerivation rec {
  name = "dbus-1.10.10";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    multihash = "QmbMf7PkUhkcdygFYWNZ7eJUZxDEUkaxQ6HGw5YifARqtB";
    allowHashOutput = false;
    sha256 = "9d8f1d069ab4d1a0255d7b400ea3bcef4430c42e729b1012abb2890e3f739a43";
  };

  buildInputs = [
    audit_lib
    expat
    libcap-ng
    systemd_lib
    xorg.xproto
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "DA98 F25C 0871 C49A 59EA  FF2C 4DE8 FF2A 63C7 CC90";
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
