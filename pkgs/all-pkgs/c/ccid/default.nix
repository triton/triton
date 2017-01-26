{ stdenv
, fetchurl
, perl

, pcsc-lite_lib
, libusb
}:

let
  name = "ccid-1.4.26";

  tarballUrls = id: [
    "https://alioth.debian.org/frs/download.php/file/${id}/${name}.tar.bz2"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = tarballUrls "4205";
    hashOutput = false;
    multihash = "QmUWnR9KYbRRUnsnh2jxhS6vhDGgk5mDFWhr5EWq83bG8c";
    sha256 = "3267bf708ab780c02f01f6241b7c7277cb892d30fd1179a9926a8cc0ca40be2f";
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
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls "4206");
      pgpKeyFingerprint = "F5E1 1B9F FE91 1146 F41D  953D 78A1 B4DF E8F9 C57E";
      inherit (src) urls outputHashAlgo outputHash;
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
