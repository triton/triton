{ stdenv
, fetchurl
, perl
, python2

, dbus
, libusb
, polkit
, systemd_lib

, type ? "full"
}:

let
  id = "4173";
  version = "1.8.17";

  tarballUrls = id: version: [
    "https://alioth.debian.org/frs/download.php/file/${id}/pcsc-lite-${version}.tar.bz2"
  ];
in
stdenv.mkDerivation rec {
  name = "pcsc-lite-${version}";

  src = fetchurl {
    urls = tarballUrls id version;
    allowHashOutput = false;
    sha256 = "d72b6f8654024f2a1d2de70f8f1d39776bd872870a4f453f436fd93d4312026f";
  };

  nativeBuildInputs = [
    perl
    python2
  ];

  buildInputs = [
    dbus
    libusb
    polkit
    systemd_lib
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    # The OS should care on preparing the drivers into this location
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-usbdropdir=/var/lib/pcsc/drivers"
    "--enable-confdir=/etc"
    "--enable-libudev"
    "--enable-polkit"
  ];

  preInstall = ''
    installFlagsArray+=("POLICY_DIR=$out/share/polkit-1/actions")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4173" "1.8.17";
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls "4174" "1.8.17");
      pgpKeyFingerprint = "F5E1 1B9F FE91 1146 F41D  953D 78A1 B4DF E8F9 C57E";
      inherit (src) outputHashAlgo;
      outputHash = "d72b6f8654024f2a1d2de70f8f1d39776bd872870a4f453f436fd93d4312026f";
    };
  };

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
