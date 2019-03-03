{ stdenv
, docbook-xsl
, gettext
, fetchurl
, intltool
, lib
, libxslt

, dbus-glib
, glib
, libgudev
, libimobiledevice
, libusb
, systemd_lib
, gobject-introspection
}:

let
  version = "0.99.10";
  # Upstream only publishes tarballs on gitlab in the release notes and does
  # not use the links api.
  id = "c438511024b9bc5a904f8775cfc8e4c4";
in
stdenv.mkDerivation rec {
  name = "upower-${version}";

  src = fetchurl {
    url = "https://gitlab.freedesktop.org/upower/upower/uploads/${id}/"
      + "${name}.tar.xz";
    multihash = "QmV3e555Mjxf6ZanYgk6qZzWhurtessjBrXvHg9vePvHH6";
    hashOutput = false;
    sha256 = "642251b97080ede8be6dbfeaf8f30ff6eadd6eb27aa137bc50f5b9b2295ba29d";
  };

  nativeBuildInputs = [
    docbook-xsl
    gettext
    intltool
    libxslt
  ];

  buildInputs = [
    dbus-glib
    glib
    gobject-introspection
    libgudev
    libimobiledevice
    libusb
    systemd_lib
  ];

  postPatch = /* Fix deprecated libimobiledevice variable */ ''
    sed -i src/linux/up-device-idevice.c \
      -e 's/LOCKDOWN_E_NOT_ENOUGH_DATA/LOCKDOWN_E_RECEIVE_TIMEOUT/'
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-udevrulesdir=$out/lib/udev/rules.d"
      "--with-systemdutildir=$out/lib/systemd"
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-maintainer-mode"
    "--enable-introspection"
    "--enable-deprecated"
    "--enable-manpages"
    "--with-backend=linux"
    "--enable-idevice"
  ];

  preInstall = ''
    installFlagsArray+=(
      "historydir=$TMPDIR"
      "sysconfdir=$out/etc"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha1Confirm = "9b452bc3d85d749d63644c51cc2fa0465890f659";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A D-Bus service for power management";
    homepage = https://upower.freedesktop.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
