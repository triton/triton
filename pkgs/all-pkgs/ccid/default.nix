{ stdenv
, fetchurl
, perl

, pcsclite
, libusb
}:

stdenv.mkDerivation rec {
  name = "ccid-1.4.22";

  src = fetchurl {
    url = "https://alioth.debian.org/frs/download.php/file/4162/ccid-1.4.22.tar.bz2";
    sha256 = "01n1b3grmz18dl8p545yfqnnwxsaq8hafzkspqb37lxncpj8np4w";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    libusb
    pcsclite
  ];

  preConfigure = ''
    # Perl scripts are using /usr/bin/env and need to be patched
    patchShebangs .

    # We dont have /bin/echo
    sed -i 's,/bin/echo,echo,g' src/Makefile.in

    configureFlagsArray+=("--enable-usbdropdir=$out/pcsc/drivers")
  '';

  meta = with stdenv.lib; {
    description = "ccid drivers for pcsclite";
    homepage = http://pcsclite.alioth.debian.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
