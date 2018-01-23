{ stdenv
, fetchurl

, libusb
}:

stdenv.mkDerivation rec {
  name = "usbredir-0.7.1";

  src = fetchurl {
    url = "https://www.spice-space.org/download/usbredir/${name}.tar.bz2";
    multihash = "QmXhMC78U1DDnwiCBdeEmNEMYghBtp9NPKrvwmroCPSWMS";
    sha256 = "407e9e27a1369f01264d5501ffbe88935ddd7d5de675f5835db05dc9c9ac56f3";
  };

  buildInputs = [
    libusb
  ];

  postPatch = ''
    sed -i 's, -Werror,,' configure
  '';

  meta = with stdenv.lib; {
    description = "Protocol headers for the SPICE protocol";
    homepage = http://www.spice-space.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
