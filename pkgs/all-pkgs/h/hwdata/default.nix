{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "0.320";
in
stdenv.mkDerivation rec {
  name = "hwdata-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "vcrhonek";
    repo = "hwdata";
    rev = "v${version}";
    sha256 = "5493463bea4c084db19a57d2d810595f92d8c21f577154a9ba72301966805e9b";
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
