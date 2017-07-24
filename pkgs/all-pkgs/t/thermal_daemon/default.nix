{ stdenv
, autoreconfHook
, fetchFromGitHub

, dbus
, dbus-glib
, glib
, libxml2
}:

let
  version = "1.6";
in
stdenv.mkDerivation {
  name = "thermal_daemon-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "01org";
    repo = "thermal_daemon";
    rev = "v${version}";
    sha256 = "961a86075dab0f46206bf667f0fe0ad1feb7a97fca049dfd8b3f7aaf1c7c6c7b";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    libxml2
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "DBUS_SYS_DIR=$out/etc/dbus-1/system.d"
      "sysconfdir=$out/etc"
      "tdconfdir=$out/etc/thermald"
      "upstartconfdir=$TMPDIR"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
