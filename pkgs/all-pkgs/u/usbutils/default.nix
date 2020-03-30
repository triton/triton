{ stdenv
, autoreconfHook
, fetchurl

, hwdata
, libusb_1
, systemd_lib
}:

let
  tarballUrls = version: [
    "mirror://kernel/linux/utils/usb/usbutils/usbutils-${version}.tar"
  ];

  version = "012";
in
stdenv.mkDerivation rec {
  name = "usbutils-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls version);
    hashOutput = false;
    sha256 = "88634625f91840bc1993d2731cc081ee8d3b13d56069a95bdd6ac6ef0e063e46";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libusb_1
    systemd_lib
  ];

  postInstall = ''
    substituteInPlace $out/bin/lsusb.py \
      --replace /usr/share/usb.ids ${hwdata}/share/hwdata/usb.ids
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.sign") (tarballUrls version);
      pgpKeyFingerprint = "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.linux-usb.org/;
    description = "Tools for working with USB devices, such as lsusb";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
