{ stdenv
, fetchurl
, perl

, pcsc-lite_lib
, libusb
}:

let
  name = "ccid-1.4.28";

  tarballUrls = id: [
    "https://alioth.debian.org/frs/download.php/file/${id}/${name}.tar.bz2"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = tarballUrls "4230";
    hashOutput = false;
    multihash = "QmYD2PrFU8SGtKTffruUfB8jEdRrg8SrAeRmTSuog1Rj2U";
    sha256 = "875836ac5d9d952b40dc1a253a726e74361671864d81337285a3260268f8ade0";
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
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls "4231");
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
