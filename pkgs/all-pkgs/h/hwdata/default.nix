{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "0.316";
in
stdenv.mkDerivation rec {
  name = "hwdata-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "vcrhonek";
    repo = "hwdata";
    rev = "v${version}";
    sha256 = "7b990e7abf0900cd82980b41aec76a3574f2cf9e1f22fddc9692966e3a665ffb";
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
