{ stdenv
, fetchurl
, perl

, pcsc-lite_lib
, libusb
}:

stdenv.mkDerivation rec {
  name = "ccid-1.4.30";

  src = fetchurl {
    url = "https://ccid.apdu.fr/files/${name}.tar.bz2";
    multihash = "QmdvYzHHYqCZsQZdh4eNoiWjt8KCtZJEvBV4RRgRZhbCeP";
    hashOutput = false;
    sha256 = "ac17087be08880a0cdf99a8a2799a4ef004dc6ffa08b4d9b0ad995f39a53ff7c";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    libusb
    pcsc-lite_lib
  ];

  postPatch = ''
    # Perl scripts are using /usr/bin/env and need to be patched
    patchShebangs .

    # We dont have /bin/echo
    sed -i 's,/bin/echo,echo,g' src/Makefile.in
  '';

  preConfigure = ''
    configureFlagsArray+=("--enable-usbdropdir=$out/pcsc/drivers")
  '';

  configureFlags = [
    "--enable-composite-as-multislot"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHashAlgo
        outputHash;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "F5E1 1B9F FE91 1146 F41D  953D 78A1 B4DF E8F9 C57E";
      };
    };
  };

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
