{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "0.311";
in
stdenv.mkDerivation rec {
  name = "hwdata-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "vcrhonek";
    repo = "hwdata";
    rev = "v${version}";
    sha256 = "19ba68d3e7ebd0e2c333be93924cc42299cb2fa9b656a6d704046c68e1dbb804";
  };

  postPatch = ''
    patchShebangs configure
  '';

  preConfigure = ''
    configureFlagsArray+=("--datadir=$out/share")
  '';

  meta = with lib; {
    description = "Hardware Database, including Monitors, pci.ids, usb.ids, and video cards";
    homepage = "https://fedorahosted.org/hwdata/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
