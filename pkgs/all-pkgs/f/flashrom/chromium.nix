{ stdenv
, fetchzip

, dtc
, libftdi
, libusb
, libusb-compat
, pciutils
}:

let
  date = "2017-03-30";
  rev = "cc04a455585bbbf52861f9c28ec03e50a04cacff";
in
stdenv.mkDerivation rec {
  name = "flashrom-chromium-2017-03-30";

  src = fetchzip {
    version = 2;
    stripRoot = false;
    purgeTimestamps = true;
    url = "https://chromium.googlesource.com/chromiumos/third_party/flashrom/+archive/${rev}.tar.gz";
    multihash = "QmPngpMFAqmG4PQndmV5UaymqPGpdowbLZonba8Hpg5f7J";
    sha256 = "f2110ea3d25098e2326d44eeb7ae6796de8b116cd18688757a8666ba18408411";
  };

  buildInputs = [
    dtc
    libftdi
    libusb
    libusb-compat
    pciutils
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
