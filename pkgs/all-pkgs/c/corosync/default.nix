{ stdenv
, fetchurl

, dbus
, libqb
, nss
, nspr
, zlib
}:

let
  version = "2.4.4";

  urlPrefix = "http://build.clusterlabs.org/corosync/releases/corosync-${version}";
in
stdenv.mkDerivation rec {
  name = "corosync-${version}";

  src = fetchurl {
    url = "${urlPrefix}.tar.gz";
    multihash = "Qme6AekH7MjtEiMR2atupVzx6nQVT6e6LQfh1VQwgXnL8E";
    hashOutput = false;
    sha256 = "9bd4707bb271df16f8d543ec782eb4c35ec0330b7be696b797da4bd8f058a25d";
  };

  buildInputs = [
    dbus
    libqb
    nss
    nspr
    zlib
  ];

  # Services are run via systemd so don't try and secure the path
  # This makes it harder to customize
  postPatch = ''
    grep -r '^PATH="' -l init | xargs sed -i '/^PATH=/d'
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemddir=$out/lib/systemd/system"
      "--with-logrotatedir=$out/etc/logrotate.d"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-secure-build"
    "--enable-dbus"
    "--enable-watchdog"
    "--enable-systemd"
    "--enable-xmlconf"
    "--enable-qdevices"
    "--enable-qnetd"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
      "COROSYSCONFDIR=$out/etc/corosync"
      "LOGDIR=$TMPDIR"
    )
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      sha256Urls = [ "${urlPrefix}.sha256" ];
      pgpsigSha256Urls = map (n: "${n}.asc") sha256Urls;
      pgpKeyFingerprints = [
        # Corosync release signing
        "9EEF A710 5EAA 4930 32A1  3320 DFD0 15CA 555C B020"
      ];
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
