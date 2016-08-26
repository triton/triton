{ stdenv
, autoreconfHook
, fetchFromGitHub

, dbus
, dbus-glib
, glib
, libxml2
}:

let
  version = "1.5.3";
in
stdenv.mkDerivation {
  name = "thermal_daemon-${version}";

  src = fetchFromGitHub {
    owner = "01org";
    repo = "thermal_daemon";
    rev = "v${version}";
    sha256 = "d7b9adc66aa60875f544d356622c4cae245469c4fb01bffcaf41a2d5093d4b96";
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
