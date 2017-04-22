{ stdenv
, fetchurl

, audit_lib
, expat
, libcap-ng
, systemd_lib
, xorg
}:

stdenv.mkDerivation rec {
  name = "dbus-1.10.18";

  src = fetchurl {
    url = "https://dbus.freedesktop.org/releases/dbus/${name}.tar.gz";
    multihash = "QmXoHHNbkFZCjzj3cNTcqTEejEd5QEcB2nXixvm43xPc7d";
    hashOutput = false;
    sha256 = "6049ddd5f3f3e2618f615f1faeda0a115104423a7996b7aa73e2f36e38cc514a";
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
      pgpKeyFingerprints = [
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
