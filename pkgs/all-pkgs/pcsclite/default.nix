{ stdenv
, fetchurl
, perl
, python2

, dbus
, libusb
# , systemd_lib
}:

stdenv.mkDerivation rec {
  name = "pcsclite-1.8.16";

  src = fetchurl {
    url = "https://alioth.debian.org/frs/download.php/file/4164/pcsc-lite-1.8.16.tar.bz2";
    sha256 = "e7d08aa38897e86fdf632d56ac70663a3a9add3c0bf4031dc32e783f19c0688a";
  };

  nativeBuildInputs = [
    perl
    python2
  ];

  buildInputs = [
    dbus
    libusb
    # systemd_lib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    # The OS should care on preparing the drivers into this location
    "--enable-usbdropdir=/var/lib/pcsc/drivers"
    "--enable-confdir=/etc"

    # Sometiems the udev code makes pcscd hit 100%
    "--disable-libudev"
  ];

  meta = with stdenv.lib; {
    description = "Middleware to access a smart card using SCard API (PC/SC)";
    homepage = http://pcsclite.alioth.debian.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
