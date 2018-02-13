{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "0.309";
in
stdenv.mkDerivation rec {
  name = "hwdata-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "vcrhonek";
    repo = "hwdata";
    rev = "v${version}";
    sha256 = "a376fb831b6700ccfdc75cd32106149e5ad8fbd2f157282e0f46e64a165b0be3";
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
