{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "0.334";
in
stdenv.mkDerivation rec {
  name = "hwdata-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "vcrhonek";
    repo = "hwdata";
    rev = "v${version}";
    sha256 = "971e75ea22241f20ffaa5a369a507b2527c6e987d7f8655708c68567d61f1896";
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
