{ stdenv
, fetchzip

, libftdi
, libusb
, libusb-compat
, pciutils
}:

let
  date = "2017-04-06";
  rev = "342740e71571ec249a7150f7b31359d55990b9d3";
in
stdenv.mkDerivation rec {
  name = "flashrom-chromium-${date}";

  src = fetchzip {
    version = 2;
    stripRoot = false;
    purgeTimestamps = true;
    url = "https://chromium.googlesource.com/chromiumos/third_party/flashrom/+archive/${rev}.tar.gz";
    multihash = "QmXsFsjC5fEyH1dPXhraMf1mfWWe1A3Mwivq2meFpMf7t2";
    sha256 = "6015a091c06214cccdb9854ae81a3241df3dcf99bb621a45f098065316e57c8f";
  };

  buildInputs = [
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
