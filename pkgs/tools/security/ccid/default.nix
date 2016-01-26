{ stdenv, fetchurl, pcsclite, pkgconfig, libusb_1, perl }:

stdenv.mkDerivation rec {
  version = "1.4.21";
  name = "ccid-${version}";

  src = fetchurl {
    url = "https://alioth.debian.org/frs/download.php/file/4148/ccid-1.4.21.tar.bz2";
    sha256 = "16wigzcs58dvjdsxpkyvjhsf9lz6cmdjmlgnh466iyjlc16awcdv";
  };

  patchPhase = ''
    patchShebangs .
    substituteInPlace src/Makefile.in --replace /bin/echo echo
  '';

  preConfigure = ''
    configureFlagsArray+=("--enable-usbdropdir=$out/pcsc/drivers")
  '';

  nativeBuildInputs = [ pkgconfig perl ];
  buildInputs = [ pcsclite libusb_1 ];

  meta = with stdenv.lib; {
    description = "ccid drivers for pcsclite";
    homepage = http://pcsclite.alioth.debian.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ viric wkennington ];
    platforms = platforms.linux;
  };
}
