{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "0.312";
in
stdenv.mkDerivation rec {
  name = "hwdata-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "vcrhonek";
    repo = "hwdata";
    rev = "v${version}";
    sha256 = "1084bce8e98fe03c84d61c0b5b5fb8234ca3623955cb4c3f306e93d69c34625b";
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
