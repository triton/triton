{ stdenv
, fetchurl
, perl

, pcsc-lite_lib
, libusb
}:

let
  name = "ccid-1.4.29";

  tarballUrls = id: [
    "https://alioth.debian.org/frs/download.php/file/${id}/${name}.tar.bz2"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = tarballUrls "4238";
    multihash = "QmVJEjQGgUa5DPMXDqMrMPNsS8r3zvfAZsvtt8eMZbnhem";
    hashOutput = false;
    sha256 = "a5432ae845730493c04e59304b5c0c6103cd0e2c8827df57d69469a3eaaab84d";
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
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls "4239");
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
