{ stdenv
, fetchurl
, perl
, python2

, dbus
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "pcsclite-1.8.14";

  src = fetchurl {
    url = "https://alioth.debian.org/frs/download.php/file/4138/pcsc-lite-1.8.14.tar.bz2";
    sha256 = "0kik09dif6hih09vvprd7zvj31lnrclrbrh5y10mlca2c209f7xr";
  };

  nativeBuildInputs = [
    perl
    python2
  ];

  buildInputs = [
    systemd_lib
    dbus
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
