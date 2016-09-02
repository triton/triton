{ stdenv
, fetchurl
, perl

, pcsc-lite_lib
, libusb
}:

let
  name = "ccid-1.4.24";

  tarballUrls = id: [
    "https://alioth.debian.org/frs/download.php/file/${id}/${name}.tar.bz2"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = tarballUrls "4171";
    hashOutput = false;
    multihash = "QmZvuvFEBVHAXC25QuuA7uV63VRbtuugh263iezUtZpQtP";
    sha256 = "62cb73c6c009c9799c526f05a05e25f00f0ad86d50f82a714dedcfbf4a7e4176";
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
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls "4172");
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
