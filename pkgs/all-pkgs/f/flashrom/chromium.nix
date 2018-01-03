{ stdenv
, fetchzip

, libftdi
, libusb
, libusb-compat
, pciutils
}:

let
  date = "2017-11-03";
  rev = "831c609f0faf5dc565d1415b6fe851c85e8c6b46";
in
stdenv.mkDerivation rec {
  name = "flashrom-chromium-${date}";

  src = fetchzip {
    version = 5;
    stripRoot = false;
    purgeTimestamps = true;
    url = "https://chromium.googlesource.com/chromiumos/third_party/flashrom/+archive/${rev}.tar.gz";
    multihash = "Qmf2MyLaW6CvKm7RcvbQoXQeWGRW9RFqGQw2rKPBhjgHGZ";
    sha256 = "9ba0e4c16dd260698a37d295fb44f6b5a98430f65b7bd6933312ac921d572b59";
  };

  buildInputs = [
    libftdi
    libusb
    libusb-compat
    pciutils
  ];

  makeFlags = [
    "CONFIG_LINUX_I2C=y"
    "CONFIG_LINUX_MTD=y"
    "WARNERROR=no"
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
